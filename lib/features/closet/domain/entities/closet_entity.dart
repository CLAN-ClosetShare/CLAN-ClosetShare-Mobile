import 'package:equatable/equatable.dart';

class ClosetEntity extends Equatable {
  final String id;
  final String name;
  final String type;
  final String? image;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int itemCount;
  final String? description;

  const ClosetEntity({
    required this.id,
    required this.name,
    required this.type,
    this.image,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.itemCount = 0,
    this.description,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    image,
    userId,
    createdAt,
    updatedAt,
    itemCount,
    description,
  ];

  ClosetEntity copyWith({
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
    return ClosetEntity(
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
}
