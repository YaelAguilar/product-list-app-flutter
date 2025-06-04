import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '/domain/entities/cart_entity.dart';
import '/domain/entities/product_entity.dart';
import '/domain/repositories/cart_repository.dart';

class UpdateCartItemQuantity implements UseCase<CartEntity, UpdateCartItemQuantityParams> {
  final CartRepository repository;

  UpdateCartItemQuantity(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(UpdateCartItemQuantityParams params) async {
    return await repository.updateCartItemQuantity(params.product, params.newQuantity);
  }
}

class UpdateCartItemQuantityParams extends Equatable {
  final ProductEntity product;
  final int newQuantity;

  const UpdateCartItemQuantityParams({required this.product, required this.newQuantity});

  @override
  List<Object?> get props => [product, newQuantity];
}