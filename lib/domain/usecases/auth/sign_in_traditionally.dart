import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '/domain/entities/user_entity.dart';
import '/domain/repositories/auth_repository.dart';

class SignInTraditionally implements UseCase<UserEntity, SignInTraditionallyParams> {
  final AuthRepository repository;

  SignInTraditionally(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInTraditionallyParams params) async {
    return await repository.signInTraditionally(params.username, params.password);
  }
}

class SignInTraditionallyParams extends Equatable {
  final String username;
  final String password;

  const SignInTraditionallyParams({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}