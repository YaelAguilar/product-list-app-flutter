import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '/domain/entities/cart_entity.dart';
import '/domain/entities/product_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, CartEntity>> getCart();
  Future<Either<Failure, CartEntity>> addProductToCart(ProductEntity product, int quantity);
  Future<Either<Failure, CartEntity>> removeProductFromCart(ProductEntity product, int quantityToRemove);
  Future<Either<Failure, CartEntity>> updateCartItemQuantity(ProductEntity product, int newQuantity);
  Future<Either<Failure, Map<String, dynamic>>> checkoutCart();
  Future<Either<Failure, CartEntity>> clearCart();
}