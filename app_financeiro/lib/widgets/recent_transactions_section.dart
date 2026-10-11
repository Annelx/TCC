import 'package:flutter/material.dart';
import 'transaction_history_screen.dart';

/// De onde a transação veio: digitada na mão pelo usuário, ou importada
/// automaticamente via Pluggy Connect (quando essa integração existir).
enum OrigemTransacao { manual, openFinance }

/// Modelo simples só pra esse esboço funcionar com dados fictícios.
/// Quando o Luís definir o transaction_model.dart real, é só trocar essa
/// classe pelo import do modelo de verdade — os campos abaixo (categoria,
/// descricao, valor, data, tipo, origem) devem servir de referência do que
/// precisa existir lá.
class TransacaoMock {
  final int? id;
  final String categoria;
  final IconData icone;
  final String descricao;
  final double valor;
  final DateTime data;
  final bool isEntrada; // true = entrada (verde), false = saída (vermelho)
  final OrigemTransacao origem;
  final String? nomeBanco; // só preenchido quando origem == openFinance

  const TransacaoMock({
    this.id,
    required this.categoria,
    required this.icone,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.isEntrada,
    this.origem = OrigemTransacao.manual,
    this.nomeBanco,
  });
}

/// Seção "Transações recentes" pra colocar abaixo do gráfico de gastos por
/// categoria no Dashboard. Mostra as últimas transações e um botão pra ver
/// o histórico completo (com busca por período/mês).
class RecentTransactionsSection extends StatelessWidget {
  static const roxo = Color(0xFF8A2BE2);

  final List<TransacaoMock> transacoes;

  const RecentTransactionsSection({super.key, required this.transacoes});

  // Dados fictícios só pra pré-visualização — remover quando plugar dados reais
  static List<TransacaoMock> get mock => [
        TransacaoMock(
          categoria: 'Alimentação',
          icone: Icons.restaurant_outlined,
          descricao: 'Supermercado Extra',
          valor: 187.40,
          data: DateTime.now().subtract(const Duration(hours: 3)),
          isEntrada: false,
          origem: OrigemTransacao.openFinance,
          nomeBanco: 'Nubank',
        ),
        TransacaoMock(
          categoria: 'Salário',
          icone: Icons.attach_money,
          descricao: 'Pagamento mensal',
          valor: 3500.00,
          data: DateTime.now().subtract(const Duration(days: 1)),
          isEntrada: true,
          origem: OrigemTransacao.openFinance,
          nomeBanco: 'Banco do Brasil',
        ),
        TransacaoMock(
          categoria: 'Transporte',
          icone: Icons.directions_car_outlined,
          descricao: 'Combustível',
          valor: 120.00,
          data: DateTime.now().subtract(const Duration(days: 2)),
          isEntrada: false,
        ),
        TransacaoMock(
          categoria: 'Lazer',
          icone: Icons.movie_outlined,
          descricao: 'Cinema',
          valor: 65.00,
          data: DateTime.now().subtract(const Duration(days: 3)),
          isEntrada: false,
        ),
      ];

  String _formatarData(DateTime data) {
    final hoje = DateTime.now();
    final diferenca = hoje.difference(data).inDays;
    if (diferenca == 0) return 'Hoje';
    if (diferenca == 1) return 'Ontem';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final recentes = transacoes.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transações recentes',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TransactionHistoryScreen(transacoes: transacoes),
                  ),
                );
              },
              child: const Text('Ver histórico completo'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (recentes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('Nenhuma transação registrada ainda',
                  style: TextStyle(color: Colors.white38)),
            ),
          )
        else
          ...recentes.map((transacao) {
            final cor = transacao.isEntrada ? const Color(0xFF4CD97B) : const Color(0xFFFF6B6B);
            final sinal = transacao.isEntrada ? '+' : '-';
            final viaOpenFinance = transacao.origem == OrigemTransacao.openFinance;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: roxo.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(transacao.icone, color: roxo, size: 20),
                      ),
                      if (viaOpenFinance)
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1A1A1A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.account_balance, size: 12, color: Colors.white54),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(transacao.descricao,
                            style: const TextStyle(color: Colors.white, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(
                          viaOpenFinance
                              ? '${transacao.categoria} · ${transacao.nomeBanco} · ${_formatarData(transacao.data)}'
                              : '${transacao.categoria} · ${_formatarData(transacao.data)}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$sinal R\$ ${transacao.valor.toStringAsFixed(2)}',
                    style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}