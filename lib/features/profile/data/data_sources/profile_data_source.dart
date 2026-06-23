import 'dart:convert';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/shared_preferences_service.dart';
import '../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> saveProfile(ProfileModel profile);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferencesService preferencesService;

  const ProfileLocalDataSourceImpl(this.preferencesService);

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final rawProfile = preferencesService.getValue(AppConstants.userProfile);
      if (rawProfile != null) {
        return ProfileModel.fromJson(
          jsonDecode(rawProfile) as Map<String, dynamic>,
        );
      }

      final rawUser = preferencesService.getValue(AppConstants.sessionUser);
      if (rawUser != null) {
        final user = jsonDecode(rawUser) as Map<String, dynamic>;
        return ProfileModel.fromJson(user);
      }

      throw const CacheException('No saved profile found.');
    } on CacheException {
      rethrow;
    } catch (_) {
      throw const CacheException('Unable to load profile.');
    }
  }

  @override
  Future<ProfileModel> saveProfile(ProfileModel profile) async {
    try {
      await preferencesService.saveValue(
        AppConstants.userProfile,
        jsonEncode(profile.toJson()),
      );
      await _syncSessionUser(profile);
      return profile;
    } catch (_) {
      throw const CacheException('Unable to save profile.');
    }
  }

  Future<void> _syncSessionUser(ProfileModel profile) async {
    final rawUser = preferencesService.getValue(AppConstants.sessionUser);
    if (rawUser == null) return;

    final user = jsonDecode(rawUser) as Map<String, dynamic>;
    user
      ..['name'] = profile.name
      ..['email'] = profile.email
      ..['bio'] = profile.bio;
    await preferencesService.saveValue(
      AppConstants.sessionUser,
      jsonEncode(user),
    );
  }
}
