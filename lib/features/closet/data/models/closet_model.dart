import '../../domain/entities/closet_entity.dart';

class ClosetModel extends ClosetEntity {
  const ClosetModel({
    required super.id,
    required super.name,
    required super.type,
    super.image,
    required super.userId,
    required super.createdAt,
    required super.updatedAt,
    super.itemCount = 0,
    super.description,
  });

  factory ClosetModel.fromJson(Map<String, dynamic> json) {
    return ClosetModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      image: json['image']?.toString(),
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      itemCount: int.tryParse(json['item_count']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'image': image,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'item_count': itemCount,
      'description': description,
    };
  }

  Map<String, dynamic> toCreateJson() {
    final json = <String, dynamic>{'name': name, 'type': type};

    if (description != null) json['description'] = description;
    if (image != null) json['image'] = image;

    return json;
  }

  Map<String, dynamic> toUpdateJson() {
    final json = <String, dynamic>{};

    json['name'] = name;
    json['type'] = type;
    if (description != null) json['description'] = description;
    if (image != null) json['image'] = image;

    return json;
  }

  @override
  ClosetModel copyWith({
    String? id,
    String? name,
    String? type,
    String? image,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? itemCount,
    String? description,
  }) {
    return ClosetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      image: image ?? this.image,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      itemCount: itemCount ?? this.itemCount,
      description: description ?? this.description,
    );
  }

  // Static helper methods
  static List<ClosetModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => ClosetModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Closet type constants
  static const List<String> closetTypes = [
    'TOPS',
    'OUTERWEAR',
    'BOTTOMS',
    'DRESSES',
    'SHOES',
    'ACCESSORIES',
    'BAGS',
    'UNDERWEAR',
    'SPORTSWEAR',
    'FORMAL',
  ];

  // Get Vietnamese name for closet type
  static String getTypeDisplayName(String type) {
    switch (type) {
      case 'TOPS':
        return 'Áo';
      case 'OUTERWEAR':
        return 'Áo khoác';
      case 'BOTTOMS':
        return 'Quần';
      case 'DRESSES':
        return 'Váy đầm';
      case 'SHOES':
        return 'Giày dép';
      case 'ACCESSORIES':
        return 'Phụ kiện';
      case 'BAGS':
        return 'Túi xách';
      case 'UNDERWEAR':
        return 'Đồ lót';
      case 'SPORTSWEAR':
        return 'Đồ thể thao';
      case 'FORMAL':
        return 'Trang phục công sở';
      default:
        return type;
    }
  }
}
