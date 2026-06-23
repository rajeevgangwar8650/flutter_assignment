import 'package:dartz/dartz.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../data_sources/profile_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  const ProfileRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      return Right(await localDataSource.getProfile());
    } catch (error) {
      return Left(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileEntity profile) async {
    try {
      final savedProfile = await localDataSource.saveProfile(
        ProfileModel.fromEntity(profile),
      );
      return Right(savedProfile);
    } catch (error) {
      return Left(ErrorHandler.toFailure(error));
    }
  }
}
