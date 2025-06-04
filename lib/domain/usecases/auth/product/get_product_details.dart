import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '/domain/entities/product_entity.dart';
import '/domain/repositories/product_repository.dart';

class GetProductDetails implements UseCase<ProductEntity, GetProductDetailsParams> {
  final ProductRepository repository;

  GetProductDetails(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(GetProductDetailsParams params) async {
    return await repository.getProductDetails(params.id);
  }
}

class GetProductDetailsParams extends Equatable {
  final int id;

  const GetProductDetailsParams({required this.id});

  @override
  List<Object?> get props => [id];
}