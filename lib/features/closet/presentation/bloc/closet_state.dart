import 'package:equatable/equatable.dart';
import '../../domain/entities/closet_entity.dart';

abstract class ClosetState extends Equatable {
  const ClosetState();

  @override
  List<Object?> get props => [];
}

class ClosetInitial extends ClosetState {}

class ClosetLoading extends ClosetState {}

class ClosetLoaded extends ClosetState {
  final List<ClosetEntity> closets;

  const ClosetLoaded(this.closets);

  @override
  List<Object> get props => [closets];
}

class ClosetError extends ClosetState {
  final String message;

  const ClosetError(this.message);

  @override
  List<Object> get props => [message];
}

class ClosetOperationInProgress extends ClosetState {}

class ClosetOperationSuccess extends ClosetState {
  final String message;
  final List<ClosetEntity> closets;

  const ClosetOperationSuccess({required this.message, required this.closets});

  @override
  List<Object> get props => [message, closets];
}
