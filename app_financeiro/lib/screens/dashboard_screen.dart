import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/recent_transactions_section.dart';
import '../models/meta_model.dart';
import '../services/dashboard_service.dart';
import 'notification_center_screen.dart';
import 'insights_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String apelido;
  final List<TransacaoMock> transacoes;
  final List<Meta> metas;
  const DashboardScreen({super.key, required this.apelido, required this.transacoes, this.metas = const []});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const roxo = Color(0xFF8A2BE2);
  final _service = DashboardService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = _service.summary();
  }

  Future<void> _refreshFromGesture() async {
    try {
      final refreshed = await _service.summary();
      if (!mounted) return;
      setState(() {
        _future = Future.value(refreshed);
      });
    } catch (error, stackTrace) {
      if (!mounted) return;
      setState(() {
        _future = Future<Map<String, dynamic>>.error(error, stackTrace);
      });
    }
  }
  double _number(dynamic value) => double.tryParse(value.toString()) ?? 0;
  String _money(dynamic value) => 'R\$ ${_number(value).toStringAsFixed(2).replaceAll('.', ',')}';

  Widget _panel(String title, Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 14), child,
    ]),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: RefreshIndicator(
      onRefresh: _refreshFromGesture,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data;
          final categories = data == null ? <dynamic>[] : (data['categories'] as List<dynamic>);
          final goals = data == null ? <dynamic>[] : (data['goals'] as List<dynamic>);
          final insights = data == null ? <dynamic>[] : (data['insights'] as List<dynamic>);
          const colors = [roxo, Color(0xFFB388FF), Color(0xFF64B5F6), Color(0xFF4CD97B), Color(0xFFFFB74D), Color(0xFF9E9E9E)];
          return ListView(padding: const EdgeInsets.all(20), children: [
            Row(children: [
              Expanded(child: Text('Olá, ${widget.apelido}! 👋', style: Theme.of(context).textTheme.headlineSmall)),
              IconButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationCenterScreen())), icon: const Icon(Icons.notifications_outlined)),
            ]),
            const Text('Aqui está seu resumo financeiro.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 18),
            if (snapshot.connectionState == ConnectionState.waiting && data == null)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (snapshot.hasError)
              _panel('Não foi possível carregar', Column(children: [
                Text('${snapshot.error}', style: const TextStyle(color: Colors.white70)),
                TextButton(onPressed: () { setState(() { _refresh(); }); }, child: const Text('Tentar novamente')),
              ]))
            else if (data != null) ...[
              _panel('Resumo do mês', Column(children: [
                Row(children: [
                  Expanded(child: _metric('Saldo do mês', _money(data['balance']), const Color(0xFF4CD97B))),
                  Expanded(child: _metric('Despesas', _money(data['expenses']), const Color(0xFFFF6B6B))),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _metric('Receitas', _money(data['income']), Colors.white)),
                  Expanded(child: _metric('Renda declarada', _money(data['monthly_income_declared']), Colors.white70)),
                ]),
                const SizedBox(height: 10),
                const Text('Saldo = receitas menos despesas registradas no mês. Renda declarada é exibida separadamente.', style: TextStyle(fontSize: 11, color: Colors.white54)),
              ])),
              const SizedBox(height: 16),
              _panel('Metas', goals.isEmpty
                ? const Text('Nenhuma meta cadastrada', style: TextStyle(color: Colors.white70))
                : Column(children: goals.take(3).map((item) {
                    final goal = Map<String, dynamic>.from(item as Map);
                    final progress = _number(goal['progress']).clamp(0.0, 1.0);
                    return Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [Expanded(child: Text(goal['name'].toString())), Text('${(progress * 100).toStringAsFixed(0)}%')]),
                      const SizedBox(height: 6), LinearProgressIndicator(value: progress, color: roxo, backgroundColor: Colors.white12),
                    ]));
                  }).toList())),
              const SizedBox(height: 16),
              _panel('Gastos por categoria', categories.isEmpty
                ? const Text('Sem despesas registradas neste mês.', style: TextStyle(color: Colors.white70))
                : Row(children: [
                    SizedBox(width: 116, height: 116, child: PieChart(PieChartData(
                      sectionsSpace: 2, centerSpaceRadius: 30,
                      sections: categories.asMap().entries.map((entry) => PieChartSectionData(
                        value: _number((entry.value as Map)['percentage']),
                        color: colors[entry.key % colors.length], radius: 23, showTitle: false,
                      )).toList(),
                    ))),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: categories.asMap().entries.map((entry) {
                      final item = Map<String, dynamic>.from(entry.value as Map);
                      return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
                        Icon(Icons.circle, size: 10, color: colors[entry.key % colors.length]), const SizedBox(width: 6),
                        Expanded(child: Text(item['name'].toString(), style: const TextStyle(fontSize: 11))),
                        Text('${_number(item['percentage']).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11)),
                      ]));
                    }).toList())),
                  ])),
              const SizedBox(height: 16),
              TextButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InsightsScreen())), icon: const Icon(Icons.insights), label: const Text('Ver alertas e recomendações')),
              _panel('Análise de consumo', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (data['income_commitment_percentage'] != null)
                  Text('Comprometimento da renda: ${_number(data['income_commitment_percentage']).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white70)),
                if (data['expense_change_percentage'] != null)
                  Text('Variação das despesas: ${_number(data['expense_change_percentage']).toStringAsFixed(1)}% em relação ao mês anterior', style: const TextStyle(color: Colors.white70)),
                ...insights.map((item) => Padding(padding: const EdgeInsets.only(top: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.lightbulb_outline, color: roxo, size: 18), const SizedBox(width: 8),
                  Expanded(child: Text(item.toString(), style: const TextStyle(color: Colors.white70))),
                ]))),
                if (insights.isEmpty) const Text('Nenhum alerta identificado nos registros deste mês.', style: TextStyle(color: Colors.white70)),
              ])),
              const SizedBox(height: 18),
              RecentTransactionsSection(transacoes: widget.transacoes),
            ],
          ]);
        },
      ),
    )),
  );

  Widget _metric(String title, String value, Color color) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 11, color: Colors.white54)),
    const SizedBox(height: 5),
    Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: color)),
  ]);
}
