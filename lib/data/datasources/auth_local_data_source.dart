import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/exceptions.dart';
import '/data/models/user_model.dart';

const String CACHED_AUTH_TOKEN = 'CACHED_AUTH_TOKEN';
const String CACHED_USER_DATA = 'CACHED_USER_DATA';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> cacheUserData(UserModel userModel);
  Future<UserModel?> getUserData();
  Future<void> clearUserData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheToken(String token) {
    return sharedPreferences.setString(CACHED_AUTH_TOKEN, token);
  }

  @override
  Future<String?> getToken() {
    final token = sharedPreferences.getString(CACHED_AUTH_TOKEN);
    if (token != null) {
      return Future.value(token);
    } else {
      return Future.value(null);
    }
  }
  
  @override
  Future<void> clearToken() {
    return sharedPreferences.remove(CACHED_AUTH_TOKEN);
  }

  @override
  Future<void> cacheUserData(UserModel userModel) {
    if (userModel.authProvider == AuthProvider.traditional && userModel.traditionalUserData != null) {
      return sharedPreferences.setString(CACHED_USER_DATA, jsonEncode(userModel.traditionalUserData));
    }
    return Future.value();
  }

  @override
  Future<UserModel?> getUserData() async {
    final jsonString = sharedPreferences.getString(CACHED_USER_DATA);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        final token = await getToken();
        if (token != null) {
          jsonMap['token'] = token;
        }
        return Future.value(UserModel.fromJson(jsonMap));
      } catch (e) {
        throw CacheException('Error al decodificar datos de usuario cacheados: $e');
      }
    } else {
      return Future.value(null);
    }
  }

  @override
  Future<void> clearUserData() {
    return sharedPreferences.remove(CACHED_USER_DATA);
  }
}