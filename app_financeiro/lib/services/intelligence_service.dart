import 'api_service.dart';
import 'auth_service.dart';

class IntelligenceService {
  final _api = ApiService();
  final _auth = AuthService();

  Future<Map<String, dynamic>> insights() async {
    final token = await _auth.savedToken();
    if (token == null) throw StateError('Sessão expirada. Faça login novamente.');
    return _api.get('/intelligence/insights', token: token);
  }
}
