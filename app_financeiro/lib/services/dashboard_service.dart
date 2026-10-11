import 'api_service.dart';
import 'auth_service.dart';

class DashboardService {
  final _api = ApiService();
  final _auth = AuthService();

  Future<Map<String, dynamic>> summary({DateTime? month}) async {
    final token = await _auth.savedToken();
    if (token == null) throw StateError('Sessão expirada. Faça login novamente.');
    final date = month ?? DateTime.now();
    return _api.get('/dashboard/summary?year=${date.year}&month=${date.month}', token: token);
  }
}
