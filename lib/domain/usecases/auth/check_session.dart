import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '/domain/repositories/auth_repository.dart';

class CheckSession implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  CheckSession(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.hasActiveTraditionalSession();
  }
}