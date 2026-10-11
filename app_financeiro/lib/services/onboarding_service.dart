import 'api_service.dart';
import 'auth_service.dart';
import '../models/onboarding_data.dart';

class OnboardingService {
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();

  Future<void> complete(OnboardingData data) async {
    final token = await _auth.savedToken();
    if (token == null) {
      throw ApiException(statusCode: 401, message: 'Sessão expirada. Entre novamente.');
    }
    await _api.post('/onboarding/complete', token: token, body: data.toJson());
  }
}
