import 'package:dartz/dartz.dart';
import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';
import '/data/datasources/auth_local_data_source.dart';
import '/data/datasources/auth_remote_data_source.dart';
import '/domain/entities/user_entity.dart';
import '/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final userModel = await remoteDataSource.signInWithGoogle();
      return Right(userModel);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado en signInWithGoogle: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInTraditionally(String username, String password) async {
    try {
      final userModel = await remoteDataSource.signInTraditionally(username, password);
      if (userModel.token != null) {
        await localDataSource.cacheToken(userModel.token!);
      }
      await localDataSource.cacheUserData(userModel);
      return Right(userModel);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado en signInTraditionally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      final firebaseUser = await remoteDataSource.getFirebaseUser();
      await remoteDataSource.signOut(firebaseUser != null);

      await localDataSource.clearToken();
      await localDataSource.clearUserData();
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al cerrar sesión: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getFirebaseUser() async {
    try {
      final userModel = await remoteDataSource.getFirebaseUser();
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error obteniendo usuario Firebase: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUserData() async {
    try {
      final token = await localDataSource.getToken();
      if (token != null) {
        final cachedUser = await localDataSource.getUserData();
        if (cachedUser != null && cachedUser.token == token) {
          return Right(cachedUser);
        } else {
          try {
            final userFromApi = await remoteDataSource.getCurrentTraditionalUser(token);
            await localDataSource.cacheUserData(userFromApi);
            return Right(userFromApi);
          } on ServerException catch (e) {
            await localDataSource.clearToken();
            await localDataSource.clearUserData();
            return Left(AuthenticationFailure('Sesión tradicional inválida o expirada: ${e.message}'));
          }
        }
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado obteniendo datos de usuario: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasActiveTraditionalSession() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token != null && token.isNotEmpty);
    } catch (e) {
      return Left(CacheFailure('Error al verificar sesión tradicional: ${e.toString()}'));
    }
  }
}