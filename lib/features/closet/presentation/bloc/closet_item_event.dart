import 'package:equatable/equatable.dart';

abstract class ClosetItemEvent extends Equatable {
  const ClosetItemEvent();

  @override
  List<Object?> get props => [];
}

class LoadClosetItems extends ClosetItemEvent {
  final String closetId;

  const LoadClosetItems(this.closetId);

  @override
  List<Object> get props => [closetId];
}

class RefreshClosetItems extends ClosetItemEvent {
  final String closetId;

  const RefreshClosetItems(this.closetId);

  @override
  List<Object> get props => [closetId];
}

class CreateClosetItemEvent extends ClosetItemEvent {
  final String closetId;
  final String name;
  final String brand;
  final String category;
  final String color;
  final String size;
  final double price;
  final List<String> images;
  final String? description;
  final String condition;

  const CreateClosetItemEvent({
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
  });

  @override
  List<Object?> get props => [
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
  ];
}

class UpdateClosetItemEvent extends ClosetItemEvent {
  final String id;
  final String closetId;
  final String? name;
  final String? brand;
  final String? category;
  final String? color;
  final String? size;
  final double? price;
  final List<String>? images;
  final String? description;
  final String? condition;
  final bool? isAvailable;

  const UpdateClosetItemEvent({
    required this.id,
    required this.closetId,
    this.name,
    this.brand,
    this.category,
    this.color,
    this.size,
    this.price,
    this.images,
    this.description,
    this.condition,
    this.isAvailable,
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
  ];
}

class DeleteClosetItemEvent extends ClosetItemEvent {
  final String id;
  final String closetId;

  const DeleteClosetItemEvent({required this.id, required this.closetId});

  @override
  List<Object> get props => [id, closetId];
}
