import 'package:equatable/equatable.dart';

abstract class ClosetEvent extends Equatable {
  const ClosetEvent();

  @override
  List<Object?> get props => [];
}

class LoadClosets extends ClosetEvent {}

class RefreshClosets extends ClosetEvent {}

class CreateClosetEvent extends ClosetEvent {
  final String name;
  final String type;
  final String? image;
  final String? description;

  const CreateClosetEvent({
    required this.name,
    required this.type,
    this.image,
    this.description,
  });

  @override
  List<Object?> get props => [name, type, image, description];
}

class UpdateClosetEvent extends ClosetEvent {
  final String id;
  final String? name;
  final String? type;
  final String? image;
  final String? description;

  const UpdateClosetEvent({
    required this.id,
    this.name,
    this.type,
    this.image,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, type, image, description];
}

class DeleteClosetEvent extends ClosetEvent {
  final String id;

  const DeleteClosetEvent(this.id);

  @override
  List<Object> get props => [id];
}
