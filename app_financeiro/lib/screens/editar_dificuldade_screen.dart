import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tela "Dificuldade financeira" — edição pós-onboarding de quais
/// dificuldades se aplicam ao usuário. Salva localmente via
/// SharedPreferences; quando o Luís tiver o endpoint, trocar por uma
/// chamada real.
class EditarDificuldadeScreen extends StatefulWidget {
  const EditarDificuldadeScreen({super.key});

  @override
  State<EditarDificuldadeScreen> createState() => _EditarDificuldadeScreenState();
}

class _EditarDificuldadeScreenState extends State<EditarDificuldadeScreen> {
  static const roxo = Color(0xFF8A2BE2);
  static const _chave = 'perfil_dificuldades';

  static const _opcoes = [
    ('gastos_desnecessarios', 'Identificar gastos desnecessários'),
    ('economizar', 'Economizar dinheiro'),
    ('organizar_gastos', 'Organizar meus gastos'),
    ('controlar_cartao', 'Controlar cartão de crédito'),
    ('planejar_metas', 'Planejar minhas metas'),
    ('controle_financeiro', 'Manter o controle financeiro'),
    ('sair_dividas', 'Sair das dívidas'),
    ('outro', 'Outro'),
  ];

  Set<String> _selecionadas = {};
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _selecionadas = (prefs.getStringList(_chave) ?? []).toSet();
      _carregando = false;
    });
  }

  void _toggle(String id) {
    setState(() {
      if (_selecionadas.contains(id)) {
        _selecionadas.remove(id);
      } else {
        _selecionadas.add(id);
      }
    });
  }

  Future<void> _salvar() async {
    if (_selecionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ao menos uma opção')),
      );
      return;
    }

    setState(() => _salvando = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_chave, _selecionadas.toList());

    // TODO: enviar pro back-end quando o Luís tiver o endpoint pronto
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    setState(() => _salvando = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dificuldades atualizadas')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: roxo)));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dificuldade financeira')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Selecione as opções que mais se aplicam a você.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ..._opcoes.map((opcao) {
              final (id, label) = opcao;
              final selecionado = _selecionadas.contains(id);
              return GestureDetector(
                onTap: () => _toggle(id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: selecionado ? roxo.withOpacity(0.25) : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selecionado ? roxo : const Color(0xFF2A2A2A),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selecionado ? Icons.check_box : Icons.check_box_outline_blank,
                        color: selecionado ? roxo : const Color(0xFF666666),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _salvando ? null : _salvar,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _salvando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Salvar alterações'),
            ),
          ],
        ),
      ),
    );
  }
}