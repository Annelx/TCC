import 'package:flutter/material.dart';

/// Tela "Alterar senha" — pede a senha atual e a nova senha (com confirmação).
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _obscureAtual = true;
  bool _obscureNova = true;
  bool _obscureConfirmar = true;
  bool _salvando = false;

  @override
  void dispose() {
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    // TODO: enviar pro back-end (ex: POST /auth/alterar-senha) com
    // senha atual + nova senha, quando o Luís tiver o endpoint pronto.
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _salvando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha alterada (mock) — falta integrar com o backend')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar senha')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _senhaAtualController,
                  obscureText: _obscureAtual,
                  decoration: InputDecoration(
                    labelText: 'Senha atual',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureAtual ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureAtual = !_obscureAtual),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe sua senha atual';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _novaSenhaController,
                  obscureText: _obscureNova,
                  decoration: InputDecoration(
                    labelText: 'Nova senha',
                    helperText: 'Mínimo 8 caracteres, com letra e número',
                    helperMaxLines: 2,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNova ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureNova = !_obscureNova),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe a nova senha';
                    }
                    if (value.length < 8) {
                      return 'Senha inválida: mínimo de 8 caracteres';
                    }
                    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
                      return 'Senha inválida: precisa ter uma letra';
                    }
                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Senha inválida: precisa ter um número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmarSenhaController,
                  obscureText: _obscureConfirmar,
                  decoration: InputDecoration(
                    labelText: 'Confirmar nova senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmar ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirmar = !_obscureConfirmar),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirme a nova senha';
                    }
                    if (value != _novaSenhaController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _salvando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar nova senha'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}