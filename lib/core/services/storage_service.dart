import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_config.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Token Management
  Future<bool> saveToken(String token) async {
    return await prefs.setString(AppConfig.tokenKey, token);
  }

  String? getToken() {
    return prefs.getString(AppConfig.tokenKey);
  }

  Future<bool> removeToken() async {
    return await prefs.remove(AppConfig.tokenKey);
  }

  // Refresh Token
  Future<bool> saveRefreshToken(String token) async {
    return await prefs.setString(AppConfig.refreshTokenKey, token);
  }

  String? getRefreshToken() {
    return prefs.getString(AppConfig.refreshTokenKey);
  }

  Future<bool> removeRefreshToken() async {
    return await prefs.remove(AppConfig.refreshTokenKey);
  }

  // User Data
  Future<bool> saveUserEmail(String email) async {
    return await prefs.setString(AppConfig.userEmailKey, email);
  }

  String? getUserEmail() {
    return prefs.getString(AppConfig.userEmailKey);
  }

  Future<bool> saveUserRole(String role) async {
    return await prefs.setString(AppConfig.userRoleKey, role);
  }

  String? getUserRole() {
    return prefs.getString(AppConfig.userRoleKey);
  }

  Future<bool> saveUserName(String name) async {
    return await prefs.setString(AppConfig.userNameKey, name);
  }

  String? getUserName() {
    return prefs.getString(AppConfig.userNameKey);
  }

  // Clear All Data
  Future<bool> clearAll() async {
    return await prefs.clear();
  }

  // Generic Methods
  Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return prefs.getInt(key);
  }

  Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  bool containsKey(String key) {
    return prefs.containsKey(key);
  }
}
