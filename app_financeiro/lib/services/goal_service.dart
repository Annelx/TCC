import '../models/meta_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class GoalService {
  final _api = ApiService();
  final _auth = AuthService();

  Future<String> _token() async {
    final token = await _auth.savedToken();
    if (token == null) throw StateError('Sessão expirada. Faça login novamente.');
    return token;
  }

  Future<List<Meta>> list() async {
    final items = await _api.getList('/goals', token: await _token());
    return items.map((item) => Meta.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<Meta> save(Meta goal) async {
    final token = await _token();
    final result = goal.id == null
        ? await _api.post('/goals', body: goal.toJson(), token: token)
        : await _api.put('/goals/${goal.id}', body: goal.toJson(), token: token);
    return Meta.fromJson(result);
  }

  Future<void> delete(int id) async {
    await _api.delete('/goals/$id', token: await _token());
  }
}
