import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/closet_entity.dart';
import '../repositories/closet_repository.dart';

class GetClosets {
  final ClosetRepository repository;

  GetClosets(this.repository);

  Future<Either<Failure, List<ClosetEntity>>> call() async {
    return await repository.getClosets();
  }
}

class GetClosetById {
  final ClosetRepository repository;

  GetClosetById(this.repository);

  Future<Either<Failure, ClosetEntity>> call(String id) async {
    return await repository.getClosetById(id);
  }
}

class CreateCloset {
  final ClosetRepository repository;

  CreateCloset(this.repository);

  Future<Either<Failure, ClosetEntity>> call({
    required String name,
    required String type,
    String? image,
    String? description,
  }) async {
    return await repository.createCloset(
      name: name,
      type: type,
      image: image,
      description: description,
    );
  }
}

class UpdateCloset {
  final ClosetRepository repository;

  UpdateCloset(this.repository);

  Future<Either<Failure, ClosetEntity>> call({
    required String id,
    String? name,
    String? type,
    String? image,
    String? description,
  }) async {
    return await repository.updateCloset(
      id: id,
      name: name,
      type: type,
      image: image,
      description: description,
    );
  }
}

class DeleteCloset {
  final ClosetRepository repository;

  DeleteCloset(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteCloset(id);
  }
}
