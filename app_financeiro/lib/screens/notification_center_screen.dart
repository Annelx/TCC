import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/intelligence_service.dart';

/// Central de alertas reais do motor de análise financeira.
/// Não são notificações push do Android: são alertas exibidos no aplicativo.
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final _service = IntelligenceService();
  late Future<Map<String, dynamic>> _future;
  bool _dicasAtivas = true;
  final Set<String> _lidas = {};

  @override
  void initState() {
    super.initState();
    _future = _service.insights();
    _carregarPreferencias();
  }

  Future<void> _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _dicasAtivas = prefs.getBool('notificacoes_dicas_ativas') ?? true;
      _lidas.addAll(prefs.getStringList('valora_alertas_lidos') ?? []);
    });
  }

  Future<void> _marcarLida(String chave) async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _lidas.add(chave));
    await prefs.setStringList('valora_alertas_lidos', _lidas.toList());
  }

  Future<void> _atualizar() async {
    final resultado = await _service.insights();

    if (!mounted) return;

    setState(() {
      _future = Future.value(resultado);
    });
  }

  IconData _icone(String nivel) {
    switch (nivel) {
      case 'critical': return Icons.error_outline;
      case 'warning': return Icons.warning_amber_outlined;
      case 'success': return Icons.trending_down;
      default: return Icons.lightbulb_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas financeiros')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Não foi possível carregar os alertas.'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _future = _service.insights();
                      });
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }
          final data = snapshot.data ?? {};
          final alertas = (data['alerts'] as List<dynamic>? ?? [])
              .map((item) => Map<String, dynamic>.from(item as Map))
              .where((item) => _dicasAtivas || item['level'] == 'critical')
              .toList();
          return RefreshIndicator(
            onRefresh: _atualizar,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text('Análise de ${data['month']}/${data['year']}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (!_dicasAtivas) const Card(child: ListTile(
                  leading: Icon(Icons.notifications_off_outlined),
                  title: Text('Dicas desativadas'),
                  subtitle: Text('Ative em Menu > Notificações para visualizar todas as recomendações.'),
                )),
                if (alertas.isEmpty) const Card(child: ListTile(
                  leading: Icon(Icons.check_circle_outline),
                  title: Text('Nenhum alerta neste momento'),
                  subtitle: Text('Registre suas movimentações para receber análises personalizadas.'),
                )),
                for (final alerta in alertas) Builder(builder: (context) {
                  final chave = '${data['year']}-${data['month']}-${alerta['code']}';
                  final lida = _lidas.contains(chave);
                  return Card(
                    child: ListTile(
                      leading: Icon(_icone('${alerta['level']}'), color: alerta['level'] == 'critical' ? Colors.redAccent : null),
                      title: Text('${alerta['title']}', style: TextStyle(fontWeight: lida ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Text('${alerta['message']}'),
                      trailing: lida ? const Icon(Icons.done, size: 18) : const Icon(Icons.circle, size: 10, color: Color(0xFF8A2BE2)),
                      onTap: () => _marcarLida(chave),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Text('${data['disclaimer'] ?? 'Orientações educativas baseadas em regras.'}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
        },
      ),
    );
  }
}
