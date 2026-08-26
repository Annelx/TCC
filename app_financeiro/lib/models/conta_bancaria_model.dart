/// Representa uma conta bancária conectada via Open Finance (Pluggy).
/// Quando o Luís integrar de verdade, os campos abaixo devem bater com o
/// que a API da Pluggy devolve (accountId, institution.name, balance, etc).
class ContaBancaria {
  final String nomeBanco;
  final String tipoConta; // 'Conta corrente', 'Cartão de crédito', etc
  final double saldo;
  final DateTime ultimaSincronizacao;

  const ContaBancaria({
    required this.nomeBanco,
    required this.tipoConta,
    required this.saldo,
    required this.ultimaSincronizacao,
  });
}