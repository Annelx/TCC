import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'valora_access_token';

  Future<String?> savedToken() => _storage.read(key: _tokenKey);
  Future<void> logout() => _storage.delete(key: _tokenKey);

  Future<Map<String, dynamic>> verifyCode({required String email, required String code}) =>
      _apiService.post('/auth/verify-code', body: {'email': email, 'code': code});

  Future<Map<String, dynamic>> resendCode({required String email}) =>
      _apiService.post('/auth/resend-code', body: {'email': email});

  Future<Map<String, dynamic>?> restoreUser() async {
    final token = await savedToken();
    if (token == null) return null;
    try {
      return await getCurrentUser(token: token);
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await logout();
        return null;
      }
      rethrow;
    }
  }


  AuthService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _apiService.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _apiService.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
    await _storage.write(key: _tokenKey, value: result['access_token'] as String);
    return result;
  }

  Future<Map<String, dynamic>> getCurrentUser({
    required String token,
  }) async {
    return _apiService.get(
      '/auth/me',
      token: token,
    );
  }
}