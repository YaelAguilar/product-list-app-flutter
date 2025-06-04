import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '/domain/entities/product_entity.dart';
import '/domain/repositories/product_repository.dart';

class SearchProducts implements UseCase<List<ProductEntity>, SearchProductsParams> {
  final ProductRepository repository;

  SearchProducts(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(SearchProductsParams params) async {
    return await repository.searchProducts(params.query);
  }
}

class SearchProductsParams extends Equatable {
  final String query;

  const SearchProductsParams({required this.query});

  @override
  List<Object?> get props => [query];
}