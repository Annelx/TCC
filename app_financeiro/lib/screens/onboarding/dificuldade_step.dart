import 'package:flutter/material.dart';
import 'onboarding_step_scaffold.dart';

/// Passo 6 do onboarding: "Qual é sua principal dificuldade financeira?"
/// Múltipla escolha.
class DificuldadeStep extends StatefulWidget {
  final List<String> selecionadasIniciais;
  final VoidCallback onVoltar;
  final void Function(List<String> dificuldades) onContinuar;

  const DificuldadeStep({
    super.key,
    this.selecionadasIniciais = const [],
    required this.onVoltar,
    required this.onContinuar,
  });

  @override
  State<DificuldadeStep> createState() => _DificuldadeStepState();
}

class _DificuldadeStepState extends State<DificuldadeStep> {
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

  late final Set<String> _selecionadas = {...widget.selecionadasIniciais};

  void _toggle(String id) {
    setState(() {
      if (_selecionadas.contains(id)) {
        _selecionadas.remove(id);
      } else {
        _selecionadas.add(id);
      }
    });
  }

  void _continuar() {
    if (_selecionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ao menos uma opção')),
      );
      return;
    }
    widget.onContinuar(_selecionadas.toList());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      icone: Icons.psychology_outlined,
      titulo: 'Qual é sua principal dificuldade financeira?',
      subtitulo: 'Selecione as opções que mais se aplicam a você.',
      passoAtual: 6,
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
        children: _opcoes.map((opcao) {
          final (id, label) = opcao;
          final selecionado = _selecionadas.contains(id);
          return GestureDetector(
            onTap: () => _toggle(id),
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
                    selecionado ? Icons.check_box : Icons.check_box_outline_blank,
                    color: selecionado ? OnboardingStepScaffold.roxo : const Color(0xFF666666),
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
        }).toList(),
      ),
    );
  }
}