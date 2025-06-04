import 'package:dartz/dartz.dart';
import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';
import '/data/datasources/cart_remote_data_source.dart';
import '/domain/entities/cart_entity.dart';
import '/domain/entities/cart_item_entity.dart';
import '/domain/entities/product_entity.dart';
import '/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartEntity _currentCart = const CartEntity();

  CartRepositoryImpl({
    required this.remoteDataSource,
  });

  CartEntity _calculateCartTotals(CartEntity cart) {
    double totalAmount = 0;
    int totalItemsCount = 0;
    for (var item in cart.items) {
      totalAmount += item.product.price * item.quantity;
      totalItemsCount += item.quantity;
    }
    return cart.copyWith(
        totalAmount: totalAmount, totalItemsCount: totalItemsCount);
  }

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    return Right(_currentCart);
  }

  @override
  Future<Either<Failure, CartEntity>> addProductToCart(ProductEntity product, int quantity) async {
    try {
      List<CartItemEntity> updatedItems = List.from(_currentCart.items);
      int existingItemIndex = updatedItems.indexWhere((item) => item.product.id == product.id);

      if (existingItemIndex != -1) {
        updatedItems[existingItemIndex] = updatedItems[existingItemIndex].copyWith(
          quantity: updatedItems[existingItemIndex].quantity + quantity,
        );
      } else {
        updatedItems.add(CartItemEntity(product: product, quantity: quantity));
      }
      _currentCart = _calculateCartTotals(CartEntity(items: updatedItems));
      return Right(_currentCart);
    } catch (e) {
      return Left(CacheFailure('Error al agregar al carrito en memoria: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeProductFromCart(ProductEntity product, int quantityToRemove) async {
    try {
      List<CartItemEntity> updatedItems = List.from(_currentCart.items);
      int existingItemIndex = updatedItems.indexWhere((item) => item.product.id == product.id);

      if (existingItemIndex != -1) {
        final currentQuantity = updatedItems[existingItemIndex].quantity;
        if (currentQuantity - quantityToRemove <= 0) {
          updatedItems.removeAt(existingItemIndex);
        } else {
          updatedItems[existingItemIndex] = updatedItems[existingItemIndex].copyWith(
            quantity: currentQuantity - quantityToRemove,
          );
        }
      }
      _currentCart = _calculateCartTotals(CartEntity(items: updatedItems));
      return Right(_currentCart);
    } catch (e) {
      return Left(CacheFailure('Error al remover del carrito en memoria: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateCartItemQuantity(ProductEntity product, int newQuantity) async {
    try {
      List<CartItemEntity> updatedItems = List.from(_currentCart.items);
      int existingItemIndex = updatedItems.indexWhere((item) => item.product.id == product.id);

      if (newQuantity <= 0) {
        if (existingItemIndex != -1) {
          updatedItems.removeAt(existingItemIndex);
        }
      } else {
        if (existingItemIndex != -1) {
          updatedItems[existingItemIndex] = updatedItems[existingItemIndex].copyWith(quantity: newQuantity);
        } else {
          return Left(ClientFailure('Intentando actualizar cantidad de producto no existente en el carrito.'));
        }
      }
      _currentCart = _calculateCartTotals(CartEntity(items: updatedItems));
      return Right(_currentCart);
    } catch (e) {
      return Left(CacheFailure('Error al actualizar cantidad en memoria: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkoutCart() async {
    if (_currentCart.items.isEmpty) {
      return Left(ClientFailure('El carrito está vacío. No se puede procesar el checkout.'));
    }
    try {
      final productsForApi = _currentCart.items.map((item) {
        return {'id': item.product.id, 'quantity': item.quantity};
      }).toList();
      
      final result = await remoteDataSource.sendCartToApi(productsForApi);
      _currentCart = const CartEntity();
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
       return Left(ServerFailure('Error desconocido durante el checkout: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> clearCart() async {
    _currentCart = const CartEntity();
    return Right(_currentCart);
  }
}