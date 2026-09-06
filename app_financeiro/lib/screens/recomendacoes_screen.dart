import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tela "Recomendações do app" — permite editar depois do onboarding a
/// frequência das recomendações e o nível de intervenção do app. Salva
/// localmente via SharedPreferences por enquanto; quando o Luís tiver o
/// endpoint pronto (ex: PUT /preferencias), trocar por uma chamada real.
class RecomendacoesScreen extends StatefulWidget {
  const RecomendacoesScreen({super.key});

  @override
  State<RecomendacoesScreen> createState() => _RecomendacoesScreenState();
}

class _RecomendacoesScreenState extends State<RecomendacoesScreen> {
  static const roxo = Color(0xFF8A2BE2);
  static const _chaveFrequencia = 'pref_frequencia_recomendacoes';
  static const _chaveNivel = 'pref_nivel_intervencao';

  static const _frequencias = [
    ('sempre', 'Sempre que algo importante acontecer'),
    ('semanal', '1 vez por semana'),
    ('mensal', '1 vez por mês'),
    ('sob_demanda', 'Somente quando eu solicitar'),
  ];

  static const _niveis = [
    ('leve', 'Leve', 'Mensagens suaves e sugestões simples'),
    ('moderado', 'Moderado', 'Alertas e recomendações mais detalhadas'),
    ('intenso', 'Intenso', 'Avisos importantes e recomendações enfáticas'),
  ];

  String _frequencia = 'semanal';
  String _nivel = 'moderado';
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarPreferencias();
  }

  Future<void> _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _frequencia = prefs.getString(_chaveFrequencia) ?? 'semanal';
      _nivel = prefs.getString(_chaveNivel) ?? 'moderado';
      _carregando = false;
    });
  }

  Future<void> _salvar() async {
    setState(() => _salvando = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveFrequencia, _frequencia);
    await prefs.setString(_chaveNivel, _nivel);

    // TODO: enviar pro back-end quando o Luís tiver o endpoint (PUT /preferencias)
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    setState(() => _salvando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferências salvas')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: roxo)));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Recomendações do app')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Frequência das recomendações',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ..._frequencias.map((opcao) {
              final (id, label) = opcao;
              return RadioListTile<String>(
                value: id,
                groupValue: _frequencia,
                onChanged: (value) => setState(() => _frequencia = value!),
                activeColor: roxo,
                contentPadding: EdgeInsets.zero,
                title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
              );
            }),

            const SizedBox(height: 24),
            const Text(
              'Nível de intervenção',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ..._niveis.map((opcao) {
              final (id, label, descricao) = opcao;
              final selecionado = _nivel == id;
              return GestureDetector(
                onTap: () => setState(() => _nivel = id),
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
                        selecionado ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: selecionado ? roxo : const Color(0xFF666666),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(descricao, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),
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