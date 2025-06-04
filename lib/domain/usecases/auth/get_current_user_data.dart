import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '/domain/entities/user_entity.dart';
import '/domain/repositories/auth_repository.dart';

class GetCurrentUserData implements UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  GetCurrentUserData(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) async {
    return await repository.getCurrentUserData();
  }
}