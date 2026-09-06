import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tela "Gastos fixos" — edição pós-onboarding dos gastos fixos por
/// categoria. Salva localmente via SharedPreferences (cada categoria vira
/// uma chave própria); quando o Luís tiver o endpoint, trocar por uma
/// chamada real.
class EditarGastosScreen extends StatefulWidget {
  const EditarGastosScreen({super.key});

  @override
  State<EditarGastosScreen> createState() => _EditarGastosScreenState();
}

class _EditarGastosScreenState extends State<EditarGastosScreen> {
  static const roxo = Color(0xFF8A2BE2);

  static const _categorias = [
    ('gasto_moradia', 'Moradia', Icons.home_outlined),
    ('gasto_contas', 'Contas (água, luz, gás)', Icons.receipt_long_outlined),
    ('gasto_internet_telefone', 'Internet / Telefone', Icons.wifi),
    ('gasto_transporte', 'Transporte', Icons.directions_car_outlined),
    ('gasto_alimentacao', 'Alimentação', Icons.restaurant_outlined),
    ('gasto_saude', 'Saúde', Icons.favorite_outline),
    ('gasto_educacao', 'Educação', Icons.school_outlined),
    ('gasto_outros', 'Outros', Icons.more_horiz),
  ];

  late final Map<String, TextEditingController> _controllers = {
    for (final categoria in _categorias) categoria.$1: TextEditingController(),
  };
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
      for (final categoria in _categorias) {
        final valor = prefs.getDouble(categoria.$1);
        if (valor != null) _controllers[categoria.$1]!.text = valor.toStringAsFixed(2);
      }
      _carregando = false;
    });
  }

  double get _total {
    double soma = 0;
    for (final controller in _controllers.values) {
      final normalizado = controller.text.replaceAll('.', '').replaceAll(',', '.');
      soma += double.tryParse(normalizado) ?? 0;
    }
    return soma;
  }

  Future<void> _salvar() async {
    setState(() => _salvando = true);
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _controllers.entries) {
      final normalizado = entry.value.text.replaceAll('.', '').replaceAll(',', '.');
      final valor = double.tryParse(normalizado) ?? 0;
      await prefs.setDouble(entry.key, valor);
    }

    // TODO: enviar pro back-end quando o Luís tiver o endpoint pronto
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    setState(() => _salvando = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gastos fixos atualizados')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: roxo)));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos fixos')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ..._categorias.map((categoria) {
              final (id, label, icone) = categoria;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _controllers[id],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: label,
                    prefixText: 'R\$ ',
                    prefixIcon: Icon(icone),
                    border: const OutlineInputBorder(),
                  ),
                ),
              );
            }),
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total de gastos fixos', style: TextStyle(color: Colors.white70)),
                  Text('R\$ ${_total.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
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