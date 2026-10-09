import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 15));

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
  }) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final dynamic data = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(data);
    }

    final message = data is Map && data['detail'] != null
        ? data['detail'].toString()
        : 'Erro na comunicação com o servidor.';

    throw ApiException(
      statusCode: response.statusCode,
      message: message,
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => message;
}