import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '/domain/entities/product_entity.dart';
import '/domain/repositories/product_repository.dart';

class GetAllProducts implements UseCase<List<ProductEntity>, NoParams> {
  final ProductRepository repository;

  GetAllProducts(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(NoParams params) async {
    return await repository.getAllProducts();
  }
}