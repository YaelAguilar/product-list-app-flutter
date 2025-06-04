import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '/domain/entities/cart_entity.dart';
import '/domain/entities/product_entity.dart';
import '/domain/repositories/cart_repository.dart';

class AddProductToCart implements UseCase<CartEntity, AddProductToCartParams> {
  final CartRepository repository;

  AddProductToCart(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(AddProductToCartParams params) async {
    return await repository.addProductToCart(params.product, params.quantity);
  }
}

class AddProductToCartParams extends Equatable {
  final ProductEntity product;
  final int quantity;

  const AddProductToCartParams({required this.product, this.quantity = 1});

  @override
  List<Object?> get props => [product, quantity];
}