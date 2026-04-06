import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/models/user_model.dart';
import '../constants/app_constants.dart';

final authStorageProvider = Provider<AuthStorage>((ref) {
  return AuthStorage();
});

class AuthStorage {
  Future<void> saveSession({required String token, required User user}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.jwtTokenKey, token);
    await prefs.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.jwtTokenKey);
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(AppConstants.userDataKey);
    if (encoded == null || encoded.isEmpty) {
      return null;
    }

    final json = jsonDecode(encoded) as Map<String, dynamic>;
    return User.fromJson(json);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.jwtTokenKey);
    await prefs.remove(AppConstants.userDataKey);
  }
}
