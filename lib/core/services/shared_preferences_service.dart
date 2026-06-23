import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class SharedPreferencesService {
  final SharedPreferences _preferences;

  SharedPreferencesService(this._preferences);

  Future<bool> clearPrefs() async {
    return _preferences.clear();
  }

  Future<bool> saveValue(String key, String value) async {
    return _preferences.setString(key, value);
  }

  String? getValue(String key) {
    return _preferences.getString(key);
  }

  String? getToken() {
    return _preferences.getString(AppConstants.token);
  }
}
