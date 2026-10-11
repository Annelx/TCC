import 'package:flutter/material.dart';
import '../widgets/recent_transactions_section.dart';
import 'api_service.dart';
import 'auth_service.dart';

class TransactionService {
  final _api = ApiService();
  final _auth = AuthService();
  Future<String> _token() async {
    final token = await _auth.savedToken();
    if (token == null) throw StateError('Sessão expirada. Faça login novamente.');
    return token;
  }

  static IconData iconFor(String category) => switch (category) {
    'Moradia' => Icons.home_outlined,
    'Alimentação' => Icons.restaurant_outlined,
    'Transporte' => Icons.directions_car_outlined,
    'Saúde' => Icons.favorite_outline,
    'Educação' => Icons.school_outlined,
    'Lazer' => Icons.movie_outlined,
    'Salário' => Icons.attach_money,
    _ => Icons.more_horiz,
  };

  TransacaoMock _fromJson(Map<String, dynamic> data) => TransacaoMock(
    id: data['id'] as int,
    descricao: data['description'] as String,
    valor: double.parse(data['amount'].toString()),
    categoria: data['category'] as String,
    icone: iconFor(data['category'] as String),
    isEntrada: data['is_income'] as bool,
    data: DateTime.parse(data['occurred_at'] as String).toLocal(),
  );

  Map<String, dynamic> _toJson(TransacaoMock t) => {
    'description': t.descricao,
    'amount': t.valor.toStringAsFixed(2),
    'category': t.categoria,
    'is_income': t.isEntrada,
    'occurred_at': t.data.toUtc().toIso8601String(),
  };

  Future<List<TransacaoMock>> getTransactions() async {
    final data = await _api.getList('/transactions', token: await _token());
    return data.map((e) => _fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<TransacaoMock> save(TransacaoMock t) async {
    final token = await _token();
    final result = t.id == null
        ? await _api.post('/transactions', body: _toJson(t), token: token)
        : await _api.put('/transactions/${t.id}', body: _toJson(t), token: token);
    return _fromJson(result);
  }

  Future<void> remove(int id) async => _api.delete('/transactions/$id', token: await _token());
}
