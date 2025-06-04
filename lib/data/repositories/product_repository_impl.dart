import 'package:dartz/dartz.dart';
import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';
import '/data/datasources/product_remote_data_source.dart';
import '/domain/entities/product_entity.dart';
import '/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({
    required this.remoteDataSource,
  });

  Future<Either<Failure, T>> _tryCatch<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado en ProductRepository: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getAllProducts() async {
    return _tryCatch(() => remoteDataSource.getAllProducts());
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductDetails(int id) async {
    return _tryCatch(() => remoteDataSource.getProductDetails(id));
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(String query) async {
    return _tryCatch(() => remoteDataSource.searchProducts(query));
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    return _tryCatch(() => remoteDataSource.getCategories());
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(String category) async {
    return _tryCatch(() => remoteDataSource.getProductsByCategory(category));
  }
}