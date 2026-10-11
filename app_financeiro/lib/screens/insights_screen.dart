import 'package:flutter/material.dart';
import '../services/intelligence_service.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});
  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _service = IntelligenceService();
  late Future<Map<String, dynamic>> _future;
  @override
  void initState() {
    super.initState();
    _future = _service.insights();
  }

  Future<void> _refresh() async {
    final result = await _service.insights();
    if (mounted) setState(() => _future = Future.value(result));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Inteligência financeira')),
    body: FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Falha ao carregar: ${snapshot.error}'),
            TextButton(onPressed: () => setState(() => _future = _service.insights()), child: const Text('Tentar novamente')),
          ]));
        }
        final data = snapshot.data!;
        final alerts = (data['alerts'] as List<dynamic>?) ?? [];
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text('Análise de ${data['month']}/${data['year']}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Despesas do mês: R\$ ${data['total_expenses']}'),
            const SizedBox(height: 16),
            ...alerts.map((raw) {
              final item = Map<String, dynamic>.from(raw as Map);
              return Card(child: ListTile(
                leading: Icon(item['level'] == 'critical' ? Icons.error_outline : Icons.lightbulb_outline),
                title: Text(item['title'].toString()),
                subtitle: Text(item['message'].toString()),
              ));
            }),
            const SizedBox(height: 16),
            Text(data['disclaimer'].toString(), style: Theme.of(context).textTheme.bodySmall),
          ]),
        );
      },
    ),
  );
}
