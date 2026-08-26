import 'package:flutter/material.dart';
import 'onboarding_step_scaffold.dart';

/// Passo 5 do onboarding: "Vamos detalhar sua meta"
/// Só é exibido quando o usuário NÃO escolheu "Sem metas" no passo 4.
class DetalhesMetaStep extends StatefulWidget {
  final String nomeMetaPrincipal; // primeiro objetivo escolhido, pro título
  final double? valorGuardarInicial;
  final double? valorAtualInicial;
  final double? valorTotalInicial;
  final DateTime? prazoInicial;
  final VoidCallback onVoltar;
  final void Function(
    double valorGuardar,
    double valorAtual,
    DateTime prazo,
    double? valorTotal,
  ) onContinuar;

  const DetalhesMetaStep({
    super.key,
    required this.nomeMetaPrincipal,
    this.valorGuardarInicial,
    this.valorAtualInicial,
    this.valorTotalInicial,
    this.prazoInicial,
    required this.onVoltar,
    required this.onContinuar,
  });

  @override
  State<DetalhesMetaStep> createState() => _DetalhesMetaStepState();
}

class _DetalhesMetaStepState extends State<DetalhesMetaStep> {
  final _formKey = GlobalKey<FormState>();
  late final _valorGuardarController = TextEditingController(
    text: widget.valorGuardarInicial?.toStringAsFixed(2) ?? '',
  );
  late final _valorAtualController = TextEditingController(
    text: widget.valorAtualInicial?.toStringAsFixed(2) ?? '',
  );
  late final _valorTotalController = TextEditingController(
    text: widget.valorTotalInicial?.toStringAsFixed(2) ?? '',
  );
  DateTime? _prazo;

  @override
  void initState() {
    super.initState();
    _prazo = widget.prazoInicial;
  }

  @override
  void dispose() {
    _valorGuardarController.dispose();
    _valorAtualController.dispose();
    _valorTotalController.dispose();
    super.dispose();
  }

  double _parse(String texto) {
    final normalizado = texto.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalizado) ?? 0;
  }

  double get _faltaGuardar {
    final guardar = _parse(_valorGuardarController.text);
    final atual = _parse(_valorAtualController.text);
    final falta = guardar - atual;
    return falta < 0 ? 0 : falta;
  }

  Future<void> _escolherPrazo() async {
    final selecionado = await showDatePicker(
      context: context,
      initialDate: _prazo ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 15)),
      helpText: 'Até quando deseja alcançar?',
    );
    if (selecionado != null) {
      setState(() => _prazo = selecionado);
    }
  }

  void _continuar() {
    if (!_formKey.currentState!.validate()) return;
    if (_prazo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha até quando deseja alcançar a meta')),
      );
      return;
    }
    widget.onContinuar(
      _parse(_valorGuardarController.text),
      _parse(_valorAtualController.text),
      _prazo!,
      _valorTotalController.text.trim().isEmpty ? null : _parse(_valorTotalController.text),
    );
  }

  static const _meses = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      icone: Icons.flag_outlined,
      titulo: 'Vamos detalhar sua meta',
      subtitulo: widget.nomeMetaPrincipal.isNotEmpty
          ? 'Meta: ${widget.nomeMetaPrincipal}'
          : 'Conte mais sobre sua meta principal.',
      passoAtual: 5,
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
              controller: _valorGuardarController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Quanto você deseja guardar?',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o valor da meta';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valorAtualController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Quanto você já possui?',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe 0 se ainda não tem nada guardado';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valorTotalController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Qual o valor total da sua meta? (opcional)',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              // sem validator — campo opcional
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _escolherPrazo,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Até quando deseja alcançar?',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _prazo != null
                      ? '${_meses[_prazo!.month - 1]} / ${_prazo!.year}'
                      : 'Selecionar data',
                  style: TextStyle(
                    color: _prazo != null ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Card "Falta guardar"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: OnboardingStepScaffold.roxo.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: OnboardingStepScaffold.roxo.withOpacity(0.4)),
              ),
              child: Text(
                'Falta guardar: R\$ ${_faltaGuardar.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}