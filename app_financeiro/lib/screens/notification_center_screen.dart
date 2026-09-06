import 'package:flutter/material.dart';

/// Um item de notificação interna do app (diferente da notificação do
/// sistema Android/iOS) — dicas, recomendações, alertas e atualizações
/// que aparecem dentro do próprio Valora.
class NotificacaoApp {
  final IconData icone;
  final String titulo;
  final String descricao;
  final DateTime data;
  final bool lida;

  const NotificacaoApp({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.data,
    this.lida = false,
  });
}

/// Tela "Notificações" (sino no topo do Dashboard): mostra dicas,
/// recomendações, alertas e atualizações do app.
///
/// Por enquanto usa dados fictícios (mock) — quando a parte de
/// inteligência (identificação de padrões de consumo) estiver pronta no
/// back-end, essa lista deve vir de um GET /notificacoes.
class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  static const roxo = Color(0xFF8A2BE2);

  static final List<NotificacaoApp> _mock = [
    NotificacaoApp(
      icone: Icons.lightbulb_outline,
      titulo: 'Dica: gastos com alimentação',
      descricao: 'Você gastou 22% do seu orçamento com alimentação este mês. Que tal planejar as refeições da semana?',
      data: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificacaoApp(
      icone: Icons.trending_up,
      titulo: 'Progresso da sua meta',
      descricao: 'Você já alcançou 20% da meta "Reserva de Emergência". Continue assim!',
      data: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificacaoApp(
      icone: Icons.warning_amber_outlined,
      titulo: 'Alerta de gasto incomum',
      descricao: 'Identificamos um gasto de R\$ 187,40 em Alimentação, acima da sua média para essa categoria.',
      data: DateTime.now().subtract(const Duration(days: 1)),
      lida: true,
    ),
    NotificacaoApp(
      icone: Icons.info_outline,
      titulo: 'Novidade no Valora',
      descricao: 'Agora você pode conectar suas contas bancárias via Pluggy Connect direto pelo Menu.',
      data: DateTime.now().subtract(const Duration(days: 3)),
      lida: true,
    ),
  ];

  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);
    if (diferenca.inHours < 1) return 'Agora há pouco';
    if (diferenca.inHours < 24) return 'Há ${diferenca.inHours}h';
    if (diferenca.inDays == 1) return 'Ontem';
    return 'Há ${diferenca.inDays} dias';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: SafeArea(
        child: _mock.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(color: roxo.withOpacity(0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_none, color: roxo, size: 36),
                    ),
                    const SizedBox(height: 20),
                    const Text('Nenhuma notificação por enquanto',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _mock.length,
                itemBuilder: (context, index) {
                  final n = _mock[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: n.lida ? const Color(0xFF1A1A1A) : roxo.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: n.lida ? null : Border.all(color: roxo.withOpacity(0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: roxo.withOpacity(0.15), shape: BoxShape.circle),
                          child: Icon(n.icone, color: roxo, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.titulo,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(n.descricao,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                              const SizedBox(height: 6),
                              Text(_formatarData(n.data),
                                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
                            ],
                          ),
                        ),
                        if (!n.lida)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(color: roxo, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}