import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tela "Notificações": liga/desliga a notificação fixa (atalho de nova
/// transação) e as notificações de dicas/recomendações do app.
class NotificacoesScreen extends StatefulWidget {
  final bool notificacaoFixaAtiva;
  final ValueChanged<bool> onAlterarNotificacaoFixa;

  const NotificacoesScreen({
    super.key,
    required this.notificacaoFixaAtiva,
    required this.onAlterarNotificacaoFixa,
  });

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  static const roxo = Color(0xFF8A2BE2);
  static const _chaveDicas = 'notificacoes_dicas_ativas';

  // Guarda o valor localmente pra refletir na tela IMEDIATAMENTE ao tocar
  // no switch, sem depender do widget pai (que fica numa rota separada)
  // se redesenhar a tempo.
  late bool _atalhoAtivo = widget.notificacaoFixaAtiva;

  bool _dicasAtivo = true;
  bool _carregandoDicas = true;

  @override
  void initState() {
    super.initState();
    _carregarPreferenciaDicas();
  }

  Future<void> _carregarPreferenciaDicas() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _dicasAtivo = prefs.getBool(_chaveDicas) ?? true;
      _carregandoDicas = false;
    });
  }

  Future<void> _alterarDicas(bool novoValor) async {
    setState(() => _dicasAtivo = novoValor); // feedback visual na hora
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveDicas, novoValor);
  }

  void _alterarAtalho(bool novoValor) {
    setState(() => _atalhoAtivo = novoValor); // feedback visual na hora
    widget.onAlterarNotificacaoFixa(novoValor); // aplica de verdade
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Material(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: SwitchListTile(
                value: _atalhoAtivo,
                onChanged: _alterarAtalho,
                activeThumbColor: roxo,
                secondary: const Icon(Icons.push_pin_outlined, color: roxo),
                title: const Text(
                  'Atalho na barra de notificações',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                subtitle: const Text(
                  'Mostra um botão fixo de "Nova transação" na barra de notificações, acessível até na tela de bloqueio — toque nele pra abrir o app direto na tela de adicionar',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: SwitchListTile(
                value: _dicasAtivo,
                onChanged: _carregandoDicas ? null : _alterarDicas,
                activeThumbColor: roxo,
                secondary: const Icon(Icons.lightbulb_outline, color: roxo),
                title: const Text(
                  'Dicas e recomendações',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                subtitle: const Text(
                  'Receba notificações com dicas, insights e recomendações personalizadas sobre suas finanças',
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
