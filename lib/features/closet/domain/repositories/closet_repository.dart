import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/closet_entity.dart';
import '../entities/closet_item_entity.dart';

abstract class ClosetRepository {
  // Closet operations
  Future<Either<Failure, List<ClosetEntity>>> getClosets();
  Future<Either<Failure, ClosetEntity>> getClosetById(String id);
  Future<Either<Failure, ClosetEntity>> createCloset({
    required String name,
    required String type,
    String? image,
    String? description,
  });
  Future<Either<Failure, ClosetEntity>> updateCloset({
    required String id,
    String? name,
    String? type,
    String? image,
    String? description,
  });
  Future<Either<Failure, void>> deleteCloset(String id);

  // Closet Item operations
  Future<Either<Failure, List<ClosetItemEntity>>> getClosetItems(
    String closetId,
  );
  Future<Either<Failure, ClosetItemEntity>> getClosetItemById(String id);
  Future<Either<Failure, ClosetItemEntity>> createClosetItem({
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
  });
  Future<Either<Failure, ClosetItemEntity>> updateClosetItem({
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
  });
  Future<Either<Failure, void>> deleteClosetItem(String id);
}
