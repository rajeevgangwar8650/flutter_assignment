import 'package:dartz/dartz.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource_impl.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> signIn({required String email, required String password}) async {
    try {
      final user = await remoteDataSource.signIn(
        email: email,
        password: password,
      );
      await localDataSource.cacheSession(user);
      return Right(user);
    } catch (error) {
      return Left(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> restoreSession() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } catch (error) {
      return Left(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearSession();
      return const Right(null);
    } catch (error) {
      return Left(ErrorHandler.toFailure(error));
    }
  }
}
