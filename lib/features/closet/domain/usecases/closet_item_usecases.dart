import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/closet_item_entity.dart';
import '../repositories/closet_repository.dart';

class GetClosetItems {
  final ClosetRepository repository;

  GetClosetItems(this.repository);

  Future<Either<Failure, List<ClosetItemEntity>>> call(String closetId) async {
    return await repository.getClosetItems(closetId);
  }
}

class GetClosetItemById {
  final ClosetRepository repository;

  GetClosetItemById(this.repository);

  Future<Either<Failure, ClosetItemEntity>> call(String id) async {
    return await repository.getClosetItemById(id);
  }
}

class CreateClosetItem {
  final ClosetRepository repository;

  CreateClosetItem(this.repository);

  Future<Either<Failure, ClosetItemEntity>> call({
    required String closetId,
    required String name,
    required String brand,
    required String category,
    required String color,
    required String size,
    required double price,
    required List<String> images,
    String? description,
    required String condition,
  }) async {
    return await repository.createClosetItem(
      closetId: closetId,
      name: name,
      brand: brand,
      category: category,
      color: color,
      size: size,
      price: price,
      images: images,
      description: description,
      condition: condition,
    );
  }
}

class UpdateClosetItem {
  final ClosetRepository repository;

  UpdateClosetItem(this.repository);

  Future<Either<Failure, ClosetItemEntity>> call({
    required String id,
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
  }) async {
    return await repository.updateClosetItem(
      id: id,
      name: name,
      brand: brand,
      category: category,
      color: color,
      size: size,
      price: price,
      images: images,
      description: description,
      condition: condition,
      isAvailable: isAvailable,
    );
  }
}

class DeleteClosetItem {
  final ClosetRepository repository;

  DeleteClosetItem(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteClosetItem(id);
  }
}
