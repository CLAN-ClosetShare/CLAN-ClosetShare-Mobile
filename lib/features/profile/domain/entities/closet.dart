class Closet {
  final String id;
  final String name;
  final String type;
  final String? image;
  final String userId;
  final DateTime createdAt;

  Closet({
    required this.id,
    required this.name,
    required this.type,
    this.image,
    required this.userId,
    required this.createdAt,
  });

  factory Closet.fromJson(Map<String, dynamic> json) {
    return Closet(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      image: json['image']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
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
    };
  }
}
