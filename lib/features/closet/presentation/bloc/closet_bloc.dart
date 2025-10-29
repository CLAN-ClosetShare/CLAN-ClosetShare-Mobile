import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/closet_usecases.dart';
import 'closet_event.dart';
import 'closet_state.dart';

class ClosetBloc extends Bloc<ClosetEvent, ClosetState> {
  final GetClosets getClosets;
  final CreateCloset createCloset;
  final UpdateCloset updateCloset;
  final DeleteCloset deleteCloset;

  ClosetBloc({
    required this.getClosets,
    required this.createCloset,
    required this.updateCloset,
    required this.deleteCloset,
  }) : super(ClosetInitial()) {
    on<LoadClosets>(_onLoadClosets);
    on<RefreshClosets>(_onRefreshClosets);
    on<CreateClosetEvent>(_onCreateCloset);
    on<UpdateClosetEvent>(_onUpdateCloset);
    on<DeleteClosetEvent>(_onDeleteCloset);
  }

  void _onLoadClosets(LoadClosets event, Emitter<ClosetState> emit) async {
    if (state is! ClosetLoaded) {
      emit(ClosetLoading());
    }

    final result = await getClosets();
    result.fold(
      (failure) => emit(ClosetError(_getFailureMessage(failure))),
      (closets) => emit(ClosetLoaded(closets)),
    );
  }

  void _onRefreshClosets(
    RefreshClosets event,
    Emitter<ClosetState> emit,
  ) async {
    final result = await getClosets();
    result.fold(
      (failure) => emit(ClosetError(_getFailureMessage(failure))),
      (closets) => emit(ClosetLoaded(closets)),
    );
  }

  void _onCreateCloset(
    CreateClosetEvent event,
    Emitter<ClosetState> emit,
  ) async {
    emit(ClosetOperationInProgress());

    final result = await createCloset(
      name: event.name,
      type: event.type,
      image: event.image,
      description: event.description,
    );

    result.fold((failure) => emit(ClosetError(_getFailureMessage(failure))), (
      newCloset,
    ) async {
      // Refresh the list after creating
      final listResult = await getClosets();
      listResult.fold(
        (failure) => emit(ClosetError(_getFailureMessage(failure))),
        (closets) => emit(
          ClosetOperationSuccess(
            message: 'Tạo tủ đồ thành công!',
            closets: closets,
          ),
        ),
      );
    });
  }

  void _onUpdateCloset(
    UpdateClosetEvent event,
    Emitter<ClosetState> emit,
  ) async {
    emit(ClosetOperationInProgress());

    final result = await updateCloset(
      id: event.id,
      name: event.name,
      type: event.type,
      image: event.image,
      description: event.description,
    );

    result.fold((failure) => emit(ClosetError(_getFailureMessage(failure))), (
      updatedCloset,
    ) async {
      // Refresh the list after updating
      final listResult = await getClosets();
      listResult.fold(
        (failure) => emit(ClosetError(_getFailureMessage(failure))),
        (closets) => emit(
          ClosetOperationSuccess(
            message: 'Cập nhật tủ đồ thành công!',
            closets: closets,
          ),
        ),
      );
    });
  }

  void _onDeleteCloset(
    DeleteClosetEvent event,
    Emitter<ClosetState> emit,
  ) async {
    emit(ClosetOperationInProgress());

    final result = await deleteCloset(event.id);
    result.fold((failure) => emit(ClosetError(_getFailureMessage(failure))), (
      _,
    ) async {
      // Refresh the list after deleting
      final listResult = await getClosets();
      listResult.fold(
        (failure) => emit(ClosetError(_getFailureMessage(failure))),
        (closets) => emit(
          ClosetOperationSuccess(
            message: 'Xóa tủ đồ thành công!',
            closets: closets,
          ),
        ),
      );
    });
  }

  String _getFailureMessage(failure) {
    return failure.message ?? 'Đã xảy ra lỗi không mong muốn';
  }
}
