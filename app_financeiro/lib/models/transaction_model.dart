class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isExpense; // true = despesa, false = receita

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isExpense,
  });
}