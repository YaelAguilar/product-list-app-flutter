import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '/domain/repositories/product_repository.dart';

class GetCategories implements UseCase<List<String>, NoParams> {
  final ProductRepository repository;

  GetCategories(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getCategories();
  }
}