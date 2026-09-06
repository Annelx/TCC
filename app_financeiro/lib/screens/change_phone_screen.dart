import 'package:flutter/material.dart';

/// Tela "Alterar telefone" — pede o telefone atual como confirmação de
/// segurança, depois libera o campo pra digitar o novo telefone.
class ChangePhoneScreen extends StatefulWidget {
  final String telefoneAtual;

  const ChangePhoneScreen({super.key, required this.telefoneAtual});

  @override
  State<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {
  static const roxo = Color(0xFF8A2BE2);

  final _formKeyConfirmacao = GlobalKey<FormState>();
  final _formKeyNovoTelefone = GlobalKey<FormState>();
  final _confirmacaoController = TextEditingController();
  final _novoTelefoneController = TextEditingController();

  bool _confirmado = false;
  bool _salvando = false;

  @override
  void dispose() {
    _confirmacaoController.dispose();
    _novoTelefoneController.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (_formKeyConfirmacao.currentState!.validate()) {
      setState(() => _confirmado = true);
    }
  }

  Future<void> _salvar() async {
    if (!_formKeyNovoTelefone.currentState!.validate()) return;

    setState(() => _salvando = true);
    // TODO: enviar pro back-end quando o Luís tiver o endpoint
    // (ex: PUT /perfil/telefone, possivelmente com verificação por SMS).
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() => _salvando = false);
    Navigator.of(context).pop(_novoTelefoneController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar telefone')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _confirmado ? _telaNovoTelefone() : _telaConfirmacao(),
        ),
      ),
    );
  }

  Widget _telaConfirmacao() {
    return Form(
      key: _formKeyConfirmacao,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_outline, color: roxo, size: 40),
          const SizedBox(height: 16),
          const Text(
            'Por segurança, confirme seu telefone atual para continuar.',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmacaoController,
            keyboardType: TextInputType.phone,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Telefone atual',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim() != widget.telefoneAtual.trim()) {
                return 'O telefone não confere';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _confirmar,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Widget _telaNovoTelefone() {
    return Form(
      key: _formKeyNovoTelefone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.phone_outlined, color: roxo, size: 40),
          const SizedBox(height: 16),
          const Text('Digite seu novo telefone.', style: TextStyle(color: Colors.white, fontSize: 15)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _novoTelefoneController,
            keyboardType: TextInputType.phone,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Novo telefone',
              hintText: '(00) 00000-0000',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe o novo telefone';
              }
              if (value.trim() == widget.telefoneAtual.trim()) {
                return 'Esse já é o seu telefone atual';
              }
              return null;
            },
          ),
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
                : const Text('Salvar novo telefone'),
          ),
        ],
      ),
    );
  }
}