import 'package:dartz/dartz.dart';
import '../core/errors/failures.dart';
import '/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> signInTraditionally(String username, String password);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity?>> getFirebaseUser();
  Future<Either<Failure, UserEntity?>> getCurrentUserData();
  Future<Either<Failure, bool>> hasActiveTraditionalSession();
}