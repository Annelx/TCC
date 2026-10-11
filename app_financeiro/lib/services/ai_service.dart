import 'api_service.dart';
import 'auth_service.dart';

class AiService {
  final _api = ApiService();
  final _auth = AuthService();

  Future<Map<String, dynamic>> ask(String question) async {
    final token = await _auth.savedToken();
    if (token == null) throw StateError('Sessão expirada. Faça login novamente.');
    return _api.post('/ai/chat', body: {'message': question}, token: token);
  }
}
