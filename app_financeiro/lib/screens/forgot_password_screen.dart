import 'package:flutter/material.dart';
import 'reset_verify_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _carregando = false;

  static const roxo = Color(0xFF8A2BE2);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _enviarCodigo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    // MOCK: aqui vai a chamada real ao back-end (POST /auth/forgot-password)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _carregando = false);

     Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ResetVerifyCodeScreen(email: _emailController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_reset, size: 56, color: roxo),
                  const SizedBox(height: 16),
                  Text(
                    'Esqueceu sua senha?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Digite seu e-mail e enviaremos um código para redefinir sua senha',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe seu e-mail';
                      }
                      final regexEmail =
                          RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
                      if (!regexEmail.hasMatch(value)) {
                        return 'E-mail inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _carregando ? null : _enviarCodigo,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _carregando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Enviar código'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}