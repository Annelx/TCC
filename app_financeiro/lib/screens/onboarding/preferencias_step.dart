import 'package:flutter/material.dart';
import 'onboarding_step_scaffold.dart';

/// Passo 7 do onboarding: "Como você gostaria de receber nossa ajuda?"
class PreferenciasStep extends StatefulWidget {
  final String frequenciaInicial;
  final String nivelInicial;
  final VoidCallback onVoltar;
  final void Function(String frequencia, String nivel) onContinuar;

  const PreferenciasStep({
    super.key,
    this.frequenciaInicial = '',
    this.nivelInicial = '',
    required this.onVoltar,
    required this.onContinuar,
  });

  @override
  State<PreferenciasStep> createState() => _PreferenciasStepState();
}

class _PreferenciasStepState extends State<PreferenciasStep> {
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

  late String _frequencia = widget.frequenciaInicial;
  late String _nivel = widget.nivelInicial;

  void _continuar() {
    if (_frequencia.isEmpty || _nivel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha uma frequência e um nível de intervenção')),
      );
      return;
    }
    widget.onContinuar(_frequencia, _nivel);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      icone: Icons.tune,
      titulo: 'Como você gostaria de receber nossa ajuda?',
      subtitulo: 'Escolha suas preferências.',
      passoAtual: 7,
      totalPassos: 7,
      onVoltar: widget.onVoltar,
      footer: ElevatedButton(
        onPressed: _continuar,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Continuar'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Frequência das recomendações',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ..._frequencias.map((opcao) {
            final (id, label) = opcao;
            return RadioListTile<String>(
              value: id,
              groupValue: _frequencia,
              onChanged: (value) => setState(() => _frequencia = value!),
              activeColor: OnboardingStepScaffold.roxo,
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
                  color: selecionado
                      ? OnboardingStepScaffold.roxo.withOpacity(0.25)
                      : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selecionado
                        ? OnboardingStepScaffold.roxo
                        : const Color(0xFF2A2A2A),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selecionado ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: selecionado ? OnboardingStepScaffold.roxo : const Color(0xFF666666),
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
        ],
      ),
    );
  }
}