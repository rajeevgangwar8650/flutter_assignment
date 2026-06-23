import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class SharedPreferencesService {
  final SharedPreferences _preferences;

  SharedPreferencesService(this._preferences);

  Future<bool?> savePrefBool(String key, bool value)async{
    return await _preferences.setBool(key, value);
  }

  Future<bool?> getPrefBool(String key)async{
    return _preferences.getBool(key);
  }

   Future<dynamic> clearPrefs(BuildContext context) async{
    return await _preferences.clear();
  }

  Future<void> saveValue(String key, String value) async {
    await _preferences.setString(key, value);
  }

  Future<String?> getValue(String key) async {
    return await _preferences.getString(key);
  }

  Future<String?> getToken() async {
    return await _preferences.getString(AppConstants.token);
  }

  Future<bool> checkIfLoggedIn() async {
    final token = await _preferences.getString(AppConstants.token);
    return token != null && token.isNotEmpty;
  }

  Future<dynamic> deleteToken() async {
    return await _preferences.remove(AppConstants.token);
  }

}
