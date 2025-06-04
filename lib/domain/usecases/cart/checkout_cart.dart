import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '/domain/repositories/cart_repository.dart';

class CheckoutCart implements UseCase<Map<String, dynamic>, NoParams> {
  final CartRepository repository;

  CheckoutCart(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    return await repository.checkoutCart();
  }
}