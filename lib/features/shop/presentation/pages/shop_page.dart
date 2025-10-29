import 'package:flutter/material.dart';
import '../../../../shared/widgets/network_image.dart';
import '../../../search/data/models/clothing_item.dart';
import 'package:closetshare/core/network/api_client.dart';
import 'package:closetshare/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:closetshare/core/storage/local_storage.dart';
import 'package:closetshare/core/di/injection_container.dart' as di;

// Simple models for filters returned by /filters
class FilterPropModel {
  final String id;
  final String name;
  bool selected;

  FilterPropModel({
    required this.id,
    required this.name,
    this.selected = false,
  });
}

class FilterModel {
  final String id;
  final String name; // display name, e.g. 'Size'
  final List<FilterPropModel> props;

  FilterModel({required this.id, required this.name, required this.props});
}

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final List<ClothingItem> _shopItems = [];
  late final ApiClient _api;
  LocalStorage? _localStorage;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;
  // Filters (generic)
  List<FilterModel> _filters = [];
  bool _filtersLoaded = false;
  static const String _filtersStorageKey = 'shop_filters_v1';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // create ApiClient locally (no DI)
    final dio = Dio();
    final dioClient = DioClient(dio);
    _api = ApiClient(dioClient);
    // try to get LocalStorage from DI if available
    try {
      _localStorage = di.sl<LocalStorage>();
    } catch (_) {
      _localStorage = null;
    }
    _fetchFilters();
    _fetchProducts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchProducts();
    }
  }

  Future<void> _fetchFilters() async {
    try {
      final res = await _api.getFilters();
      // parse generic filters: { filters: [ { id, name, props: [{id,name}] } ] }
      if (res is Map && res['filters'] is List) {
        final list = res['filters'] as List;
        final parsed = <FilterModel>[];
        for (var f in list) {
          try {
            final map = Map<String, dynamic>.from(f);
            final propsRaw = map['props'] as List? ?? [];
            final props = propsRaw.map((p) {
              final pm = Map<String, dynamic>.from(p);
              return FilterPropModel(
                id: pm['id']?.toString() ?? '',
                name: pm['name']?.toString() ?? '',
              );
            }).toList();
            parsed.add(
              FilterModel(
                id: map['id']?.toString() ?? '',
                name: map['name']?.toString() ?? '',
                props: props,
              ),
            );
          } catch (_) {}
        }
        _filters = parsed;
        // load saved selections if present
        await _loadSavedFilters();
      }
      setState(() => _filtersLoaded = true);
    } catch (e) {
      setState(() => _filtersLoaded = true);
    }
  }

  Future<void> _fetchProducts({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }
    setState(() => _isLoading = true);
    try {
      final selectedSizes = _filters
          .firstWhere(
            (f) => f.name.toLowerCase() == 'size',
            orElse: () => FilterModel(id: '', name: '', props: []),
          )
          .props
          .where((p) => p.selected)
          .map((p) => p.name)
          .toList();

      final qp = ClothingItem.buildFilterQuery(
        page: _page,
        limit: _limit,
        sizes: selectedSizes.isNotEmpty ? selectedSizes : null,
      );
      final res = await _api.getProducts(queryParameters: qp);
      final items = ClothingItem.fromApiList(res);
      setState(() {
        if (refresh) {
          _shopItems.clear();
        }
        _shopItems.addAll(items);
        if (items.length < _limit) _hasMore = false;
        _page += 1;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lấy sản phẩm thất bại: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Shop',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.photo_camera, color: Colors.black87),
          ),
          // IconButton(
          //   onPressed: () => _openFilterSheet(),
          //   icon: const Icon(Icons.tune, color: Colors.black87),
          // ),
          _buildFilterIcon(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_border, color: Colors.black87),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchProducts(refresh: true);
        },
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _shopItems.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _shopItems.length) { 
              // loading indicator at the end
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final item = _shopItems[index];
            return _buildShopCard(item);
          },
        ),
      ),
    );
  }

  Widget _buildShopCard(ClothingItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _showItemDetail(item);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite button
            Expanded(
              flex: 7,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: SharedNetworkImage(
                      imageUrl: item.images.isNotEmpty
                          ? item.images.first
                          : null,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(230),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // "Similar items" badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(179),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Similar items',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand and rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.brand,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 10,
                              color: Colors.orange.shade400,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '4.5',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Item name
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Price and shop info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.brand} x ${item.brand}',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Text(
                              '\$${item.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: item.isAvailable
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.isAvailable ? Icons.check : Icons.close,
                            size: 12,
                            color: item.isAvailable
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetail(ClothingItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SharedNetworkImage(
                        imageUrl: item.images.isNotEmpty
                            ? item.images.first
                            : null,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${item.brand} • ${item.category}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.description,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giá thuê',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '\$${item.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF00073E),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Chủ sở hữu',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              item.owner,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: item.isAvailable
                            ? () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã thêm vào giỏ hàng!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00073E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          item.isAvailable ? 'Thêm vào giỏ' : 'Hết hàng',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final h = MediaQuery.of(context).size.height * 0.75;
        return SafeArea(
          child: Container(
            height: h,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Bộ lọc',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                // Content scrolls
                Expanded(
                  child: _filtersLoaded
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ..._filters.map((filter) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        filter.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: filter.props.map((prop) {
                                          return ChoiceChip(
                                            label: Text(prop.name),
                                            selected: prop.selected,
                                            onSelected: (v) {
                                              setState(() {
                                                prop.selected = v;
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
                // Action row fixed at bottom
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              for (var filter in _filters) {
                                for (var prop in filter.props) {
                                  prop.selected = false;
                                }
                              }
                            });
                          },
                          child: const Text('Xóa'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _applyFilters();
                          },
                          child: const Text('Áp dụng'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _applyFilters() {
    // rebuild query with selected sizes
    setState(() {
      _shopItems.clear();
      _page = 1;
      _hasMore = true;
    });
    // persist selections
    _saveSelectedFilters();
    _fetchProducts(refresh: true);
  }

  int _selectedCount() {
    var c = 0;
    for (var f in _filters) {
      c += f.props.where((p) => p.selected).length;
    }
    return c;
  }

  Future<void> _saveSelectedFilters() async {
    try {
      final Map<String, dynamic> map = {};
      for (var f in _filters) {
        final ids = f.props.where((p) => p.selected).map((p) => p.id).toList();
        if (ids.isNotEmpty) map[f.id] = ids;
      }
      if (_localStorage != null) {
        await _localStorage!.saveString(_filtersStorageKey, jsonEncode(map));
      }
    } catch (_) {}
  }

  Future<void> _loadSavedFilters() async {
    try {
      if (_localStorage == null) return;
      final raw = await _localStorage!.getString(_filtersStorageKey);
      if (raw == null || raw.isEmpty) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      for (var f in _filters) {
        final saved = data[f.id] as List<dynamic>?;
        if (saved == null) continue;
        final ids = saved.map((e) => e.toString()).toSet();
        for (var p in f.props) {
          p.selected = ids.contains(p.id);
        }
      }
      setState(() {});
    } catch (_) {}
  }

  // Build filter icon with badge
  Widget _buildFilterIcon() {
    final count = _selectedCount();
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: () => _openFilterSheet(),
          icon: const Icon(Icons.tune, color: Colors.black87),
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
