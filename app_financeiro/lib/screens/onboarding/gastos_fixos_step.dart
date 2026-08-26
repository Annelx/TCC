import 'package:flutter/material.dart';
import 'onboarding_step_scaffold.dart';

/// Passo 3 do onboarding: "Quais são seus gastos fixos mensais?"
class GastosFixosStep extends StatefulWidget {
  final Map<String, double> gastosIniciais;
  final VoidCallback onVoltar;
  final void Function(Map<String, double> gastos) onContinuar;

  const GastosFixosStep({
    super.key,
    this.gastosIniciais = const {},
    required this.onVoltar,
    required this.onContinuar,
  });

  @override
  State<GastosFixosStep> createState() => _GastosFixosStepState();
}

class _GastosFixosStepState extends State<GastosFixosStep> {
  // id : (label, ícone)
  static const _categorias = [
    ('moradia', 'Moradia', Icons.home_outlined),
    ('contas', 'Contas (água, luz, gás)', Icons.receipt_long_outlined),
    ('internet_telefone', 'Internet / Telefone', Icons.wifi),
    ('transporte', 'Transporte', Icons.directions_car_outlined),
    ('alimentacao', 'Alimentação', Icons.restaurant_outlined),
    ('saude', 'Saúde', Icons.favorite_outline),
    ('educacao', 'Educação', Icons.school_outlined),
    ('outros', 'Outros', Icons.more_horiz),
  ];

  late final Map<String, TextEditingController> _controllers = {
    for (final categoria in _categorias)
      categoria.$1: TextEditingController(
        text: widget.gastosIniciais[categoria.$1] != null
            ? widget.gastosIniciais[categoria.$1]!.toStringAsFixed(2)
            : '',
      ),
  };

  double get _total {
    double soma = 0;
    for (final controller in _controllers.values) {
      final normalizado = controller.text.replaceAll('.', '').replaceAll(',', '.');
      soma += double.tryParse(normalizado) ?? 0;
    }
    return soma;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _continuar() {
    final gastos = <String, double>{};
    for (final entry in _controllers.entries) {
      final normalizado = entry.value.text.replaceAll('.', '').replaceAll(',', '.');
      final valor = double.tryParse(normalizado) ?? 0;
      if (valor > 0) gastos[entry.key] = valor;
    }
    widget.onContinuar(gastos);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      icone: Icons.home_outlined,
      titulo: 'Quais são seus gastos fixos mensais?',
      subtitulo:
          'Informe os valores aproximados dos seus principais gastos que todo mês você tem.',
      passoAtual: 3,
      totalPassos: 7,
      onVoltar: widget.onVoltar,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatefulBuilder(
            builder: (context, setStateTotal) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total de gastos fixos',
                        style: TextStyle(color: Colors.white70)),
                    Text(
                      'R\$ ${_total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: _continuar,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _categorias.map((categoria) {
          final (id, label, icone) = categoria;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: _controllers[id],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}), // atualiza o total em tempo real
              decoration: InputDecoration(
                labelText: label,
                prefixText: 'R\$ ',
                prefixIcon: Icon(icone),
                border: const OutlineInputBorder(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}