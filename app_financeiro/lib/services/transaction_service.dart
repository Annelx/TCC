import '../models/transaction_model.dart';

class TransactionService {
  Future<List<TransactionModel>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300)); // simula delay de rede
    return [
      TransactionModel(id: '1', title: 'iFood', amount: 62.90, category: 'Alimentação', date: DateTime.now(), isExpense: true),
      TransactionModel(id: '2', title: 'Uber', amount: 25.00, category: 'Transporte', date: DateTime.now(), isExpense: true),
      TransactionModel(id: '3', title: 'Salário', amount: 3000.00, category: 'Renda', date: DateTime.now(), isExpense: false),
      TransactionModel(id: '4', title: 'Netflix', amount: 39.90, category: 'Assinaturas', date: DateTime.now(), isExpense: true),
    ];
  }
}