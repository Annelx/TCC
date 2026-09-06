import 'package:flutter/material.dart';

/// Tela "Alterar e-mail" — pede o e-mail atual como confirmação de
/// segurança, depois libera o campo pra digitar o novo e-mail.
class ChangeEmailScreen extends StatefulWidget {
  final String emailAtual;

  const ChangeEmailScreen({super.key, required this.emailAtual});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  static const roxo = Color(0xFF8A2BE2);

  final _formKeyConfirmacao = GlobalKey<FormState>();
  final _formKeyNovoEmail = GlobalKey<FormState>();
  final _confirmacaoController = TextEditingController();
  final _novoEmailController = TextEditingController();

  bool _confirmado = false;
  bool _salvando = false;

  @override
  void dispose() {
    _confirmacaoController.dispose();
    _novoEmailController.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (_formKeyConfirmacao.currentState!.validate()) {
      setState(() => _confirmado = true);
    }
  }

  Future<void> _salvar() async {
    if (!_formKeyNovoEmail.currentState!.validate()) return;

    setState(() => _salvando = true);
    // TODO: enviar pro back-end quando o Luís tiver o endpoint
    // (ex: PUT /perfil/email, possivelmente com verificação por código).
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() => _salvando = false);
    Navigator.of(context).pop(_novoEmailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar e-mail')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _confirmado ? _telaNovoEmail() : _telaConfirmacao(),
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
            'Por segurança, confirme seu e-mail atual para continuar.',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmacaoController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'E-mail atual',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().toLowerCase() != widget.emailAtual.trim().toLowerCase()) {
                return 'O e-mail não confere';
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

  Widget _telaNovoEmail() {
    return Form(
      key: _formKeyNovoEmail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.email_outlined, color: roxo, size: 40),
          const SizedBox(height: 16),
          const Text('Digite seu novo e-mail.', style: TextStyle(color: Colors.white, fontSize: 15)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _novoEmailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Novo e-mail',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe o novo e-mail';
              }
              final regexEmail = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
              if (!regexEmail.hasMatch(value)) {
                return 'E-mail inválido';
              }
              if (value.trim().toLowerCase() == widget.emailAtual.trim().toLowerCase()) {
                return 'Esse já é o seu e-mail atual';
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
                : const Text('Salvar novo e-mail'),
          ),
        ],
      ),
    );
  }
}