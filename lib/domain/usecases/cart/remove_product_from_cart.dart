import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '/domain/entities/cart_entity.dart';
import '/domain/entities/product_entity.dart';
import '/domain/repositories/cart_repository.dart';

class RemoveProductFromCart implements UseCase<CartEntity, RemoveProductFromCartParams> {
  final CartRepository repository;

  RemoveProductFromCart(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(RemoveProductFromCartParams params) async {
    return await repository.removeProductFromCart(params.product, params.quantityToRemove);
  }
}

class RemoveProductFromCartParams extends Equatable {
  final ProductEntity product;
  final int quantityToRemove;

  const RemoveProductFromCartParams({required this.product, this.quantityToRemove = 1});

  @override
  List<Object?> get props => [product, quantityToRemove];
}