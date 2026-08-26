import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/recent_transactions_section.dart';

/// Tela inicial do app depois do onboarding: resumo do mês, progresso das
/// metas, gráfico de gastos por categoria e transações recentes.
///
/// Por enquanto usa dados fictícios (mock) — quando o Luís tiver os
/// endpoints prontos, trocar os valores fixos abaixo por chamadas reais
/// ao back-end (ex: GET /dashboard/resumo, GET /transacoes/recentes).
class DashboardScreen extends StatelessWidget {
  final String apelido;
  final List<TransacaoMock> transacoes;

  const DashboardScreen({super.key, required this.apelido, required this.transacoes});

  static const roxo = Color(0xFF8A2BE2);

  // ---- dados fictícios pro esboço ----
  static const _saldo = 850.00;
  static const _receitas = 3500.00;
  static const _despesas = 2650.00;
  static const _metaNome = 'Reserva de Emergência';
  static const _metaProgresso = 0.20; // 20%

  static const _categorias = [
    ('Moradia', 0.45, Color(0xFF8A2BE2)),
    ('Alimentação', 0.22, Color(0xFFB388FF)),
    ('Transporte', 0.11, Color(0xFF64B5F6)),
    ('Lazer', 0.08, Color(0xFF4CD97B)),
    ('Outros', 0.14, Color(0xFF9E9E9E)),
  ];
  // -------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Cabeçalho
            Text('Olá, $apelido! 👋', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Aqui está o resumo da sua vida financeira.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),

            // Resumo do mês
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resumo do mês', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Saldo', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            Text('R\$ ${_saldo.toStringAsFixed(2)}',
                                style: const TextStyle(color: Color(0xFF4CD97B), fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Despesas', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            Text('R\$ ${_despesas.toStringAsFixed(2)}',
                                style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Metas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Metas', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: roxo.withOpacity(0.15), shape: BoxShape.circle),
                        child: const Icon(Icons.flag_outlined, color: roxo, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_metaNome, style: const TextStyle(color: Colors.white, fontSize: 14)),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _metaProgresso,
                                minHeight: 6,
                                backgroundColor: const Color(0xFF2A2A2A),
                                valueColor: const AlwaysStoppedAnimation(roxo),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${(_metaProgresso * 100).toInt()}%',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Gastos por categoria
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gastos por categoria', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 32,
                            sections: _categorias.map((categoria) {
                              final (nome, fatia, cor) = categoria;
                              return PieChartSectionData(
                                value: fatia,
                                color: cor,
                                title: '',
                                radius: 22,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _categorias.map((categoria) {
                            final (nome, fatia, cor) = categoria;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(nome, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                  ),
                                  Text('${(fatia * 100).toInt()}%',
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Transações recentes
            RecentTransactionsSection(transacoes: transacoes),
          ],
        ),
      ),
    );
  }
}