import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getAllProducts();
  Future<Either<Failure, ProductEntity>> getProductDetails(int id);
  Future<Either<Failure, List<ProductEntity>>> searchProducts(String query);
  Future<Either<Failure, List<String>>> getCategories();
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(String category);
}