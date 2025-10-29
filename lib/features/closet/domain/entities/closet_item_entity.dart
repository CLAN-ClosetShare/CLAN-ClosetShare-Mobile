import 'package:equatable/equatable.dart';

class ClosetItemEntity extends Equatable {
  final String id;
  final String closetId;
  final String name;
  final String brand;
  final String category;
  final String color;
  final String size;
  final double price;
  final List<String> images;
  final String? description;
  final String condition; // NEW, LIKE_NEW, GOOD, FAIR, POOR
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClosetItemEntity({
    required this.id,
    required this.closetId,
    required this.name,
    required this.brand,
    required this.category,
    required this.color,
    required this.size,
    required this.price,
    required this.images,
    this.description,
    required this.condition,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    closetId,
    name,
    brand,
    category,
    color,
    size,
    price,
    images,
    description,
    condition,
    isAvailable,
    createdAt,
    updatedAt,
  ];

  ClosetItemEntity copyWith({
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
    return ClosetItemEntity(
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
}
