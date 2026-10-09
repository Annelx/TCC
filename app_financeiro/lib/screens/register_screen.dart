import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'verify_code_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();


  bool _obscureSenha = true;
  bool _obscureConfirmarSenha = true;
  bool _carregando = false;

  static const roxo = Color(0xFF8A2BE2);

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _criarConta() async {
    if (!_formKey.currentState!.validate() || _carregando) return;
    setState(() => _carregando = true);
    try {
      await AuthService().register(
        name: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        password: _senhaController.text,
      );
      if (!mounted) return;
      await _mostrarSucesso();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => VerifyCodeScreen(email: _emailController.text.trim()),
      ));
    } on ApiException catch (error) {
      if (mounted) _mostrarErro(error.message);
    } catch (_) {
      if (mounted) _mostrarErro('Não foi possível conectar à API.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _mostrarSucesso() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
        return Dialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: roxo, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: roxo.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: roxo, size: 36),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Conta criada com sucesso!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1A1A),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(mensagem, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.redAccent, width: 1),
        ),
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
                  Text(
                    'Criar conta',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preencha seus dados para começar',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // Nome
                  TextFormField(
                    controller: _nomeController,
                    keyboardType: TextInputType.name,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe seu nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // E-mail
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
                      final regexEmail = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
                      if (!regexEmail.hasMatch(value)) {
                        return 'E-mail não identificado, verifique o formato';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Telefone
                  TextFormField(
                    controller: _telefoneController,
                    keyboardType: TextInputType.phone,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      hintText: '(00) 00000-0000',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe seu telefone';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Senha
                  TextFormField(
                    controller: _senhaController,
                    obscureText: _obscureSenha,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      helperText: 'Mínimo 8 caracteres, com letra e número',
                      helperMaxLines: 2,
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureSenha
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() => _obscureSenha = !_obscureSenha);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe uma senha';
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

                  // Confirmar senha
                  TextFormField(
                    controller: _confirmarSenhaController,
                    obscureText: _obscureConfirmarSenha,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: 'Confirmar senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmarSenha
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() =>
                              _obscureConfirmarSenha = !_obscureConfirmarSenha);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirme sua senha';
                      }
                      if (value != _senhaController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botão criar conta
                  ElevatedButton(
                    onPressed: _carregando ? null : _criarConta,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _carregando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Criar conta'),
                  ),
                  const SizedBox(height: 24),

                  // Voltar para login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Já tem conta?'),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Entrar'),
                      ),
                    ],
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