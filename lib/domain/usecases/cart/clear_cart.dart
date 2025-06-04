import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '/domain/entities/cart_entity.dart';
import '/domain/repositories/cart_repository.dart';

class ClearCart implements UseCase<CartEntity, NoParams> {
  final CartRepository repository;

  ClearCart(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(NoParams params) async {
    return await repository.clearCart();
  }
}