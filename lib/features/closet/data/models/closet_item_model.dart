import '../../domain/entities/closet_item_entity.dart';

class ClosetItemModel extends ClosetItemEntity {
  const ClosetItemModel({
    required super.id,
    required super.closetId,
    required super.name,
    required super.brand,
    required super.category,
    required super.color,
    required super.size,
    required super.price,
    required super.images,
    super.description,
    required super.condition,
    super.isAvailable = true,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ClosetItemModel.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        images = (json['images'] as List)
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      } else if (json['images'] is String) {
        // Single image as string
        final img = json['images'].toString();
        if (img.isNotEmpty) images = [img];
      }
    }

    return ClosetItemModel(
      id: json['id']?.toString() ?? '',
      closetId:
          json['closet_id']?.toString() ?? json['closetId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      images: images,
      description: json['description']?.toString(),
      condition: json['condition']?.toString() ?? 'GOOD',
      isAvailable:
          json['is_available'] == true ||
          json['isAvailable'] == true ||
          (json['is_available'] == null && json['isAvailable'] == null),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'closet_id': closetId,
      'name': name,
      'brand': brand,
      'category': category,
      'color': color,
      'size': size,
      'price': price,
      'images': images,
      'description': description,
      'condition': condition,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    final json = <String, dynamic>{
      'closet_id': closetId,
      'name': name,
      'brand': brand,
      'category': category,
      'color': color,
      'size': size,
      'price': price,
      'condition': condition,
    };

    if (images.isNotEmpty) json['images'] = images;
    if (description != null) json['description'] = description;

    return json;
  }

  Map<String, dynamic> toUpdateJson() {
    final json = <String, dynamic>{
      'name': name,
      'brand': brand,
      'category': category,
      'color': color,
      'size': size,
      'price': price,
      'condition': condition,
      'is_available': isAvailable,
    };

    if (images.isNotEmpty) json['images'] = images;
    if (description != null) json['description'] = description;

    return json;
  }

  @override
  ClosetItemModel copyWith({
    String? id,
    String? closetId,
    String? name,
    String? brand,
    String? category,
    String? color,
    String? size,
    double? price,
    List<String>? images,
    String? description,
    String? condition,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClosetItemModel(
      id: id ?? this.id,
      closetId: closetId ?? this.closetId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      color: color ?? this.color,
      size: size ?? this.size,
      price: price ?? this.price,
      images: images ?? this.images,
      description: description ?? this.description,
      condition: condition ?? this.condition,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Static helper methods
  static List<ClosetItemModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => ClosetItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Condition constants
  static const List<String> conditionTypes = [
    'NEW',
    'LIKE_NEW',
    'GOOD',
    'FAIR',
    'POOR',
  ];

  // Get Vietnamese name for condition
  static String getConditionDisplayName(String condition) {
    switch (condition) {
      case 'NEW':
        return 'Mới';
      case 'LIKE_NEW':
        return 'Như mới';
      case 'GOOD':
        return 'Tốt';
      case 'FAIR':
        return 'Khá';
      case 'POOR':
        return 'Cũ';
      default:
        return condition;
    }
  }

  // Common categories
  static const List<String> commonCategories = [
    'Áo sơ mi',
    'Áo thun',
    'Áo polo',
    'Áo len',
    'Quần jean',
    'Quần tây',
    'Quần short',
    'Váy mini',
    'Váy midi',
    'Váy dài',
    'Áo khoác bomber',
    'Áo khoác da',
    'Blazer',
    'Giày thể thao',
    'Giày cao gót',
    'Sandal',
    'Túi xách',
    'Ba lô',
    'Kính mát',
    'Đồng hồ',
  ];

  // Common sizes
  static const List<String> commonSizes = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    '36',
    '37',
    '38',
    '39',
    '40',
    '41',
    '42',
    '43',
    '44',
    '45',
  ];
}
