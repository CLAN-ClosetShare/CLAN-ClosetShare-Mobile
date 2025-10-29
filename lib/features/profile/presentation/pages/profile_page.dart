import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/api_client.dart';
import '../../../../core/repositories/auth_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ApiClient _api = di.sl<ApiClient>();
  final AuthRepository _auth = di.sl<AuthRepository>();

  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _closets = [];
  Map<String, Map<String, List<dynamic>>> _closetItemsByType = {};
  bool _loading = true;
  bool _loadingClosets = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfileAndClosets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileAndClosets() async {
    setState(() {
      _loading = true;
      _loadingClosets = true;
    });

    try {
      // Fetch user info (call /users/me via ApiClient)
      try {
        final data = await _api.getUserProfile();
        if (data is Map<String, dynamic>) {
          _user = data;
        }
      } catch (e, st) {
        // log and continue
        // ignore: avoid_print
        print('Profile: error fetching /users/me -> $e\n$st');
      }

      // Fetch closets
      try {
        final res = await _api.getClosets();
        if (res is Map && res['data'] is List) {
          final list = (res['data'] as List).cast<Map<String, dynamic>>();
          _closets = list;
        } else if (res is List) {
          _closets = (res as List).cast<Map<String, dynamic>>();
        }
      } catch (e, st) {
        // log and continue
        // ignore: avoid_print
        print('Profile: error fetching closets -> $e\n$st');
        _closets = [];
      }

      // For each closet, fetch items and group by 'type'
      for (final closet in _closets) {
        final id = closet['id']?.toString() ?? closet['_id']?.toString();
        if (id == null) continue;
        try {
          final itemsRes = await _api.getClosetItems(id);
          List<dynamic> items = [];
          if (itemsRes is Map && itemsRes['data'] is List) {
            items = itemsRes['data'] as List<dynamic>;
          } else if (itemsRes is List) {
            items = itemsRes as List<dynamic>;
          }
          final Map<String, List<dynamic>> grouped = {};
          for (final it in items) {
            if (it is Map<String, dynamic>) {
              final t = (it['type'] ?? it['category'] ?? 'Khác').toString();
              grouped.putIfAbsent(t, () => []).add(it);
            }
          }
          _closetItemsByType[id] = grouped;
        } catch (e, st) {
          // log and set empty
          // ignore: avoid_print
          print('Profile: error fetching items for closet $id -> $e\n$st');
          _closetItemsByType[closet['id']?.toString() ?? closet['_id']?.toString() ?? ''] = {};
        }
      }
    } catch (e, st) {
      // Unexpected top-level error: log and notify user but avoid crash
      // ignore: avoid_print
      print('Profile: unexpected error -> $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi tải thông tin hồ sơ: $e')));
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingClosets = false;
      });
    }
  }

  Widget _buildProfileTab() {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: Colors.grey.shade200,
                    child: _user != null && _user!['avatar'] != null
                        ? ClipOval(
                            child: Image.network(
                              _user!['avatar'].toString(),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.person, size: 56, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    _user != null ? (_user!['name'] ?? _user!['username'] ?? 'Người dùng') : 'Người dùng',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _user != null ? (_user!['email'] ?? '') : '',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(height: 24),

                const Text('Thông tin cơ bản', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow('Tên', _user != null ? (_user!['name'] ?? '-') : '-'),
                        const SizedBox(height: 8),
                        _infoRow('Email', _user != null ? (_user!['email'] ?? '-') : '-'),
                        const SizedBox(height: 8),
                        _infoRow('Số điện thoại', _user != null ? (_user!['phone_number'] ?? '-') : '-'),
                        const SizedBox(height: 8),
                        _infoRow('Trạng thái', _user != null ? (_user!['status'] ?? '-') : '-'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                const Text('Thống kê', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('Tủ đồ', _closets.length.toString()),
                    _statItem('Mục', _closetItemsByType.values.fold<int>(0, (p, m) => p + m.values.fold<int>(0, (pp, l) => pp + l.length)).toString()),
                    _statItem('Theo dõi', '—'),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: edit profile
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Chỉnh sửa hồ sơ'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _auth.logout();
                          // TODO: navigate to login screen
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Đăng xuất'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
  }

  Widget _infoRow(String label, dynamic value) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(label, style: TextStyle(color: Colors.grey.shade700))),
        Expanded(flex: 4, child: Text(value?.toString() ?? '-')),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildClosetsTab() {
    if (_loadingClosets) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_closets.isEmpty) {
      return const Center(child: Text('Chưa có tủ đồ nào'));
    }

    return RefreshIndicator(
      onRefresh: _loadProfileAndClosets,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: _closets.length,
        itemBuilder: (context, idx) {
          final closet = _closets[idx];
          final id = closet['id']?.toString() ?? closet['_id']?.toString() ?? '$idx';
          final grouped = _closetItemsByType[id] ?? {};
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: Text(closet['name']?.toString() ?? 'Tủ đồ'),
              subtitle: Text('${grouped.keys.length} loại'),
              children: grouped.entries.map((e) {
                final type = e.key;
                final items = e.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (c, i) {
                            final it = items[i] as Map<String, dynamic>;
                            final img = (it['images'] is List && it['images'].isNotEmpty) ? it['images'][0].toString() : null;
                            return Container(
                              width: 110,
                              margin: const EdgeInsets.only(right: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: img != null
                                        ? Image.network(img, width: 110, height: 90, fit: BoxFit.cover)
                                        : Container(width: 110, height: 90, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(it['name']?.toString() ?? '-', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Thông tin', icon: Icon(Icons.person)),
            Tab(text: 'Tủ đồ', icon: Icon(Icons.checkroom)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildProfileTab(), _buildClosetsTab()],
      ),
    );
  }
}
