import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tela "Renda mensal" — edição pós-onboarding da renda e do tipo de renda.
/// Salva localmente via SharedPreferences; quando o Luís tiver o endpoint
/// (ex: PUT /perfil/financeiro), trocar por uma chamada real.
class EditarRendaScreen extends StatefulWidget {
  const EditarRendaScreen({super.key});

  @override
  State<EditarRendaScreen> createState() => _EditarRendaScreenState();
}

class _EditarRendaScreenState extends State<EditarRendaScreen> {
  static const roxo = Color(0xFF8A2BE2);
  static const _chaveRenda = 'perfil_renda_mensal';
  static const _chaveTipo = 'perfil_tipo_renda';

  static const _opcoes = [
    ('fixa', 'Fixa'),
    ('variavel', 'Variável'),
    ('fixa_variavel', 'Fixa + Variável'),
  ];

  final _formKey = GlobalKey<FormState>();
  final _rendaController = TextEditingController();
  String _tipoRenda = 'fixa';
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
      final renda = prefs.getDouble(_chaveRenda);
      if (renda != null) _rendaController.text = renda.toStringAsFixed(2);
      _tipoRenda = prefs.getString(_chaveTipo) ?? 'fixa';
      _carregando = false;
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final normalizado = _rendaController.text.replaceAll('.', '').replaceAll(',', '.');
    final renda = double.tryParse(normalizado) ?? 0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_chaveRenda, renda);
    await prefs.setString(_chaveTipo, _tipoRenda);

    // TODO: enviar pro back-end quando o Luís tiver o endpoint pronto
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    setState(() => _salvando = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Renda atualizada')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: roxo)));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Renda mensal')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _rendaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                const Text('Sua renda é:', style: TextStyle(color: Colors.white, fontSize: 15)),
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
                        color: selecionado ? roxo.withOpacity(0.25) : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selecionado ? roxo : const Color(0xFF2A2A2A),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
                          ),
                          if (selecionado)
                            const Icon(Icons.check_circle, color: roxo, size: 20)
                          else
                            const Icon(Icons.circle_outlined, color: Color(0xFF666666), size: 20),
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
        ),
      ),
    );
  }
}