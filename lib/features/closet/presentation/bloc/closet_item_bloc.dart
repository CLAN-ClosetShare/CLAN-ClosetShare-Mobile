import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/closet_item_usecases.dart';
import 'closet_item_event.dart';
import 'closet_item_state.dart';

class ClosetItemBloc extends Bloc<ClosetItemEvent, ClosetItemState> {
  final GetClosetItems getClosetItems;
  final CreateClosetItem createClosetItem;
  final UpdateClosetItem updateClosetItem;
  final DeleteClosetItem deleteClosetItem;

  ClosetItemBloc({
    required this.getClosetItems,
    required this.createClosetItem,
    required this.updateClosetItem,
    required this.deleteClosetItem,
  }) : super(ClosetItemInitial()) {
    on<LoadClosetItems>(_onLoadClosetItems);
    on<RefreshClosetItems>(_onRefreshClosetItems);
    on<CreateClosetItemEvent>(_onCreateClosetItem);
    on<UpdateClosetItemEvent>(_onUpdateClosetItem);
    on<DeleteClosetItemEvent>(_onDeleteClosetItem);
  }

  void _onLoadClosetItems(
    LoadClosetItems event,
    Emitter<ClosetItemState> emit,
  ) async {
    if (state is! ClosetItemLoaded) {
      emit(ClosetItemLoading());
    }

    final result = await getClosetItems(event.closetId);
    result.fold(
      (failure) => emit(ClosetItemError(_getFailureMessage(failure))),
      (items) => emit(ClosetItemLoaded(items)),
    );
  }

  void _onRefreshClosetItems(
    RefreshClosetItems event,
    Emitter<ClosetItemState> emit,
  ) async {
    final result = await getClosetItems(event.closetId);
    result.fold(
      (failure) => emit(ClosetItemError(_getFailureMessage(failure))),
      (items) => emit(ClosetItemLoaded(items)),
    );
  }

  void _onCreateClosetItem(
    CreateClosetItemEvent event,
    Emitter<ClosetItemState> emit,
  ) async {
    emit(ClosetItemOperationInProgress());

    final result = await createClosetItem(
      closetId: event.closetId,
      name: event.name,
      brand: event.brand,
      category: event.category,
      color: event.color,
      size: event.size,
      price: event.price,
      images: event.images,
      description: event.description,
      condition: event.condition,
    );

    result.fold(
      (failure) => emit(ClosetItemError(_getFailureMessage(failure))),
      (newItem) async {
        // Refresh the list after creating
        final listResult = await getClosetItems(event.closetId);
        listResult.fold(
          (failure) => emit(ClosetItemError(_getFailureMessage(failure))),
          (items) => emit(
            ClosetItemOperationSuccess(
              message: 'Thêm sản phẩm thành công!',
              items: items,
            ),
          ),
        );
      },
    );
  }

  void _onUpdateClosetItem(
    UpdateClosetItemEvent event,
    Emitter<ClosetItemState> emit,
  ) async {
    emit(ClosetItemOperationInProgress());

    final result = await updateClosetItem(
      id: event.id,
      name: event.name,
      brand: event.brand,
      category: event.category,
      color: event.color,
      size: event.size,
      price: event.price,
      images: event.images,
      description: event.description,
      condition: event.condition,
      isAvailable: event.isAvailable,
    );

    result.fold(
      (failure) => emit(ClosetItemError(_getFailureMessage(failure))),
      (updatedItem) async {
        // Refresh the list after updating
        final listResult = await getClosetItems(event.closetId);
        listResult.fold(
          (failure) => emit(ClosetItemError(_getFailureMessage(failure))),
          (items) => emit(
            ClosetItemOperationSuccess(
              message: 'Cập nhật sản phẩm thành công!',
              items: items,
            ),
          ),
        );
      },
    );
  }

  void _onDeleteClosetItem(
    DeleteClosetItemEvent event,
    Emitter<ClosetItemState> emit,
  ) async {
    emit(ClosetItemOperationInProgress());

    final result = await deleteClosetItem(event.id);
    result.fold(
      (failure) => emit(ClosetItemError(_getFailureMessage(failure))),
      (_) async {
        // Refresh the list after deleting
        final listResult = await getClosetItems(event.closetId);
        listResult.fold(
          (failure) => emit(ClosetItemError(_getFailureMessage(failure))),
          (items) => emit(
            ClosetItemOperationSuccess(
              message: 'Xóa sản phẩm thành công!',
              items: items,
            ),
          ),
        );
      },
    );
  }

  String _getFailureMessage(failure) {
    return failure.message ?? 'Đã xảy ra lỗi không mong muốn';
  }
}
