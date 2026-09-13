import 'api_service.dart';

class AuthService {
  final ApiService _apiService;

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
    return _apiService.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
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