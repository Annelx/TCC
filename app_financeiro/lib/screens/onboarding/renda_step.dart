import 'package:flutter/material.dart';
import 'onboarding_step_scaffold.dart';

/// Passo 2 do onboarding: "Qual é sua renda mensal?"
class RendaStep extends StatefulWidget {
  final double? rendaInicial;
  final String tipoRendaInicial;
  final VoidCallback onVoltar;
  final void Function(double renda, String tipoRenda) onContinuar;

  const RendaStep({
    super.key,
    this.rendaInicial,
    this.tipoRendaInicial = '',
    required this.onVoltar,
    required this.onContinuar,
  });

  @override
  State<RendaStep> createState() => _RendaStepState();
}

class _RendaStepState extends State<RendaStep> {
  final _formKey = GlobalKey<FormState>();
  late final _rendaController = TextEditingController(
    text: widget.rendaInicial != null ? widget.rendaInicial!.toStringAsFixed(2) : '',
  );
  late String _tipoRenda = widget.tipoRendaInicial;

  static const _opcoes = [
    ('fixa', 'Fixa'),
    ('variavel', 'Variável'),
    ('fixa_variavel', 'Fixa + Variável'),
  ];

  @override
  void dispose() {
    _rendaController.dispose();
    super.dispose();
  }

  void _continuar() {
    if (!_formKey.currentState!.validate()) return;
    if (_tipoRenda.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o tipo da sua renda')),
      );
      return;
    }
    final renda = double.parse(
      _rendaController.text.replaceAll('.', '').replaceAll(',', '.'),
    );
    widget.onContinuar(renda, _tipoRenda);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      icone: Icons.attach_money,
      titulo: 'Qual é sua renda mensal?',
      subtitulo:
          'Informe sua renda média para que possamos entender sua realidade financeira.',
      passoAtual: 2,
      totalPassos: 7,
      onVoltar: widget.onVoltar,
      footer: ElevatedButton(
        onPressed: _continuar,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Continuar'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _rendaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Renda média mensal',
                prefixText: 'R\$ ',
                prefixIcon: Icon(Icons.payments_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe sua renda mensal';
                }
                final normalizado = value.replaceAll('.', '').replaceAll(',', '.');
                final numero = double.tryParse(normalizado);
                if (numero == null || numero <= 0) {
                  return 'Informe um valor válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Sua renda é:',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 12),
            ..._opcoes.map((opcao) {
              final (id, label) = opcao;
              final selecionado = _tipoRenda == id;
              return GestureDetector(
                onTap: () => setState(() => _tipoRenda = id),
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
                      Expanded(
                        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                      if (selecionado)
                        const Icon(Icons.check_circle, color: OnboardingStepScaffold.roxo, size: 20)
                      else
                        const Icon(Icons.circle_outlined, color: Color(0xFF666666), size: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}