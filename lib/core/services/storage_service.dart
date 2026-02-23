import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_config.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;
  static const _secureStorage = FlutterSecureStorage();
  String? _cachedToken;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _cachedToken = await _secureStorage.read(key: AppConfig.tokenKey);
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Token Management (secure storage – paridad PENDIENTES)
  Future<bool> saveToken(String token) async {
    await _secureStorage.write(key: AppConfig.tokenKey, value: token);
    _cachedToken = token;
    return true;
  }

  String? getToken() {
    return _cachedToken;
  }

  Future<String?> getTokenAsync() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _secureStorage.read(key: AppConfig.tokenKey);
    return _cachedToken;
  }

  Future<bool> removeToken() async {
    await _secureStorage.delete(key: AppConfig.tokenKey);
    _cachedToken = null;
    return true;
  }

  // Refresh Token
  Future<bool> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConfig.refreshTokenKey, value: token);
    return true;
  }

  Future<String?> getRefreshTokenAsync() async {
    return await _secureStorage.read(key: AppConfig.refreshTokenKey);
  }

  String? getRefreshToken() {
    return null;
  }

  Future<bool> removeRefreshToken() async {
    await _secureStorage.delete(key: AppConfig.refreshTokenKey);
    return true;
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
    _cachedToken = null;
    await _secureStorage.delete(key: AppConfig.tokenKey);
    await _secureStorage.delete(key: AppConfig.refreshTokenKey);
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
