import 'package:equatable/equatable.dart';
import '../../domain/entities/closet_item_entity.dart';

abstract class ClosetItemState extends Equatable {
  const ClosetItemState();

  @override
  List<Object?> get props => [];
}

class ClosetItemInitial extends ClosetItemState {}

class ClosetItemLoading extends ClosetItemState {}

class ClosetItemLoaded extends ClosetItemState {
  final List<ClosetItemEntity> items;

  const ClosetItemLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class ClosetItemError extends ClosetItemState {
  final String message;

  const ClosetItemError(this.message);

  @override
  List<Object> get props => [message];
}

class ClosetItemOperationInProgress extends ClosetItemState {}

class ClosetItemOperationSuccess extends ClosetItemState {
  final String message;
  final List<ClosetItemEntity> items;

  const ClosetItemOperationSuccess({
    required this.message,
    required this.items,
  });

  @override
  List<Object> get props => [message, items];
}
