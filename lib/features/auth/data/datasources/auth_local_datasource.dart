import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/shared_preferences_service.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheSession(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferencesService preferencesService;
  const AuthLocalDataSourceImpl(this.preferencesService);

  @override
  Future<void> cacheSession(UserModel user) async {
    try {
      await preferencesService.saveValue(AppConstants.token, user.token);
      await preferencesService.saveValue(
        AppConstants.sessionUser,
        jsonEncode(user.toJson()),
      );
      await preferencesService.saveValue(
        AppConstants.userProfile,
        jsonEncode(<String, dynamic>{
          'name': user.name,
          'email': user.email,
          'bio': user.bio,
          'imageUrl': '',
        }),
      );
    } catch (_) {
      throw const CacheException('Unable to save session.');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final token = preferencesService.getToken();
      final rawUser = preferencesService.getValue(AppConstants.sessionUser);
      if (token == null || token.isEmpty || rawUser == null) return null;
      final decoded = jsonDecode(rawUser) as Map<String, dynamic>;
      return UserModel.fromJson(decoded);
    } catch (_) {
      throw const CacheException('Unable to restore session.');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await preferencesService.clearPrefs();
    } catch (_) {
      throw const CacheException('Unable to clear session.');
    }
  }
}
