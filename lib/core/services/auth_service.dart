import '../../features/auth/domain/entities/auth_response.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../network/api_client.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final StorageService _storage = StorageService();
  AuthRepository? _authRepository;
  ApiClient? _apiClient;

  User? _currentUser;

  void initialize(AuthRepository repository, ApiClient apiClient) {
    _authRepository = repository;
    _apiClient = apiClient;
  }

  AuthRepository get _repository {
    if (_authRepository == null) {
      throw Exception('AuthService not initialized. Call initialize() first.');
    }
    return _authRepository!;
  }

  // Login
  Future<User> login(String email, String password) async {
    final response = await _repository.login(email, password);
    await _saveAuthData(response);
    return response.user;
  }

  // Register
  Future<User> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
  }) async {
    final response = await _repository.register(
      email: email,
      password: password,
      name: name,
      role: role,
      phone: phone,
    );
    await _saveAuthData(response);
    return response.user;
  }

  // Logout
  Future<void> logout() async {
    await _repository.logout();
    await _clearAuthData();
  }

  // Check if authenticated
  bool isAuthenticated() {
    return _storage.getToken() != null;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    if (!isAuthenticated()) {
      return null;
    }

    try {
      _currentUser = await _repository.getCurrentUser();
      return _currentUser;
    } catch (e) {
      await _clearAuthData();
      return null;
    }
  }

  // Get user role
  String? getUserRole() {
    return _storage.getUserRole();
  }

  // Refresh token
  Future<bool> refreshToken() async {
    final refreshToken = _storage.getRefreshToken();
    if (refreshToken == null) {
      return false;
    }

    try {
      final newToken = await _repository.refreshToken(refreshToken);
      await _storage.saveToken(newToken);
      
      // Update API client token
      if (_apiClient != null) {
        _apiClient!.updateToken(newToken);
      }
      
      return true;
    } catch (e) {
      await _clearAuthData();
      return false;
    }
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    await _repository.forgotPassword(email);
  }

  // Reset password
  Future<void> resetPassword(String token, String newPassword) async {
    await _repository.resetPassword(token, newPassword);
  }

  // Private: Save auth data
  Future<void> _saveAuthData(AuthResponse response) async {
    await _storage.saveToken(response.token);
    if (response.refreshToken != null) {
      await _storage.saveRefreshToken(response.refreshToken!);
    }
    await _storage.saveUserEmail(response.user.email);
    await _storage.saveUserRole(response.user.role);
    await _storage.saveUserName(response.user.name);
    
    _currentUser = response.user;
    
    // Update API client token
    if (_apiClient != null) {
      _apiClient!.updateToken(response.token);
    }
  }

  // Private: Clear auth data
  Future<void> _clearAuthData() async {
    await _storage.clearAll();
    _currentUser = null;
    
    // Clear API client token
    if (_apiClient != null) {
      _apiClient!.updateToken(null);
    }
  }
}
