class ClothingItem {
  final String id;
  final String name;
  final String category;
  final String brand;
  final List<String> images;
  final double price;
  final List<String> sizes;
  final String color;
  final String description;
  final bool isAvailable;
  final String owner;

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.images,
    required this.price,
    required this.sizes,
    required this.color,
    required this.description,
    required this.isAvailable,
    required this.owner,
  });

  // Parse from API product shape (supports product -> variants -> pricings)
  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    // Try to extract price from variants.pricings
    double price = 0.0;
    List<String> sizes = [];
    int totalStock = 0;

    if (json['variants'] is List) {
      final variants = json['variants'] as List;
      if (variants.isNotEmpty) {
        // collect sizes and stock
        for (var v in variants) {
          try {
            final vMap = v as Map<String, dynamic>;
            final vName = (vMap['name'] ?? '').toString();
            if (vName.isNotEmpty) sizes.add(vName);
            final stock = int.tryParse('${vMap['stock'] ?? 0}') ?? 0;
            totalStock += stock;

            if (vMap['pricings'] is List &&
                (vMap['pricings'] as List).isNotEmpty) {
              final p = (vMap['pricings'] as List).first;
              final pMap = p as Map<String, dynamic>;
              final pVal = double.tryParse('${pMap['price'] ?? 0}') ?? 0.0;
              if (pVal > 0) {
                price = pVal;
                // break when found first valid price (keep loop to accumulate sizes/stock)
              }
            }
          } catch (_) {}
        }
      }
    }

    final images = <String>[];
    if (json['images'] is List) {
      for (var i in json['images']) {
        if (i != null) images.add(i.toString());
      }
    }

    return ClothingItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category:
          json['category']?.toString() ?? json['type']?.toString() ?? 'Khác',
      brand: json['brand']?.toString() ?? '',
      images: images,
      price: price > 0
          ? price
          : double.tryParse('${json['price'] ?? 0}') ?? 0.0,
      sizes: sizes,
      color: json['color']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isAvailable: totalStock > 0,
      owner: json['owner']?.toString() ?? json['shopName']?.toString() ?? '',
    );
  }

  // Create list from API response data (response.data['data'])
  static List<ClothingItem> fromApiList(dynamic apiData) {
    if (apiData == null) return [];
    try {
      if (apiData is List) {
        return apiData.map((e) {
          if (e is Map<String, dynamic>) return ClothingItem.fromJson(e);
          return ClothingItem.fromJson(Map<String, dynamic>.from(e));
        }).toList();
      }

      if (apiData is Map && apiData['data'] is List) {
        return (apiData['data'] as List).map((e) {
          if (e is Map<String, dynamic>) return ClothingItem.fromJson(e);
          return ClothingItem.fromJson(Map<String, dynamic>.from(e));
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  // Fallback mock data for local UI when API not available
  static List<ClothingItem> mockData = [
    ClothingItem(
      id: 'prod_1',
      name: 'Áo sơ mi trắng classic',
      category: 'Áo sơ mi',
      brand: 'Zara',
      images: ['https://picsum.photos/id/1018/600/800'],
      price: 350000,
      sizes: ['S', 'M', 'L'],
      color: 'Trắng',
      description: 'Áo sơ mi trắng cổ điển, phù hợp cho môi trường công sở',
      isAvailable: true,
      owner: 'Nguyễn Văn A',
    ),
    ClothingItem(
      id: 'prod_2',
      name: 'Váy dạ hội đen',
      category: 'Váy',
      brand: 'H&M',
      images: ['https://picsum.photos/id/1019/600/800'],
      price: 800000,
      sizes: ['S', 'M'],
      color: 'Đen',
      description:
          'Váy dạ hội sang trọng, thích hợp cho các sự kiện quan trọng',
      isAvailable: true,
      owner: 'Trần Thị B',
    ),
  ];

  // Convenience for building query params for API filter
  static Map<String, dynamic> buildFilterQuery({
    String? search,
    String? category,
    double? priceMin,
    double? priceMax,
    List<String>? sizes,
    int page = 1,
    int limit = 20,
  }) {
    final Map<String, dynamic> q = {'page': page, 'limit': limit};
    if (search != null && search.isNotEmpty) q['search'] = search;
    if (category != null && category.isNotEmpty && category != 'Tất cả')
      q['type'] = category;
    if (priceMin != null) q['price_min'] = priceMin.toInt();
    if (priceMax != null) q['price_max'] = priceMax.toInt();
    if (sizes != null && sizes.isNotEmpty) q['sizes'] = sizes.join(',');
    return q;
  }

  // Get all categories from a provided list or fallback to mockData
  static List<String> getCategories({List<ClothingItem>? from}) {
    final source = from ?? mockData;
    final Set<String> categories = {'Tất cả'};
    for (var item in source) {
      if (item.category.isNotEmpty) categories.add(item.category);
    }
    return categories.toList();
  }
}
