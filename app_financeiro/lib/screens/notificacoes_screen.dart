import 'package:flutter/material.dart';

/// Tela "Notificações": liga/desliga a notificação fixa (atalho de nova
/// transação na barra de notificações / tela de bloqueio).
class NotificacoesScreen extends StatelessWidget {
  final bool notificacaoFixaAtiva;
  final ValueChanged<bool> onAlterarNotificacaoFixa;

  const NotificacoesScreen({
    super.key,
    required this.notificacaoFixaAtiva,
    required this.onAlterarNotificacaoFixa,
  });

  static const roxo = Color(0xFF8A2BE2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                value: notificacaoFixaAtiva,
                onChanged: onAlterarNotificacaoFixa,
                activeColor: roxo,
                secondary: const Icon(Icons.push_pin_outlined, color: roxo),
                title: const Text('Atalho na barra de notificações',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text(
                  'Mostra um botão fixo de "Nova transação", acessível até na tela de bloqueio',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}