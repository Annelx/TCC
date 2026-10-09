import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'onboarding/onboarding_flow.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final LocalAuthentication _auth = LocalAuthentication();
  bool _obscureSenha = true;
  String? _mensagemErro;
  bool _carregando = false;

  static const roxo = Color(0xFF8A2BE2);

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate() || _carregando) return;
    setState(() => _carregando = true);
    try {
      final auth = AuthService();
      await auth.login(email: _emailController.text.trim(), password: _senhaController.text);
      final token = await auth.savedToken();
      final user = await auth.getCurrentUser(token: token!);
      if (!mounted) return;
      final completed = user['onboarding_completed'] == true;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => completed
          ? MainNavigation(apelido: (user['name'] ?? '').toString(), email: (user['email'] ?? '').toString())
          : OnboardingFlow(emailInicial: (user['email'] ?? '').toString(), apelidoInicial: (user['name'] ?? '').toString())),
        (_) => false,
      );
    } on ApiException catch (error) {
      if (mounted) _mostrarErro(error.message);
    } catch (_) {
      if (mounted) _mostrarErro('Não foi possível conectar à API.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
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

  void _loginComGoogle() {
    // TODO: integrar login social de verdade (Firebase Auth / Google Sign-In)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login com Google ainda não configurado')),
    );
  }
    void _loginComBiometria() async {
    try {
      final disponivel = await _auth.canCheckBiometrics;
      if (!disponivel) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometria não disponível neste dispositivo')),
        );
        return;
      }

      final autenticado = await _auth.authenticate(
        localizedReason: 'Use sua biometria para entrar no Valora',
      );

      if (!mounted) return;

      if (autenticado) {
        // TODO: validar sessão com o back-end depois da biometria confirmada
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login com biometria realizado (mock)!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na biometria: $e')),
      );
    }
  }

    void _abrirEsqueciSenha() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                                // Logo Valora
                  Center(
                    child: SizedBox(
                      width: 56,
                      child: Image.asset('assets/images/valora_logo.png'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Seja Bem-vindo',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 32),

                  // Campo de e-mail
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
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
                        return 'E-mail inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de senha
                  TextFormField(
                    controller: _senhaController,
                    obscureText: _obscureSenha,
                    decoration: InputDecoration(
                      labelText: 'Senha',
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
                        return 'Informe sua senha';
                      }
                      if (value.length < 8) {
                        return 'Senha inválida';
                      }
                      return null;
                    },
                  ),

                  // Esqueci minha senha
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _abrirEsqueciSenha,
                      child: const Text('Esqueci minha senha'),
                    ),
                  ),

                  // Mensagem de erro
                  if (_mensagemErro != null) ...[
                    Text(
                      _mensagemErro!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],

                  const SizedBox(height: 8),

                  // Botão entrar
                  ElevatedButton(
                    onPressed: _carregando ? null : _fazerLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _carregando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Entrar'),
                  ),

                  const SizedBox(height: 24),

                  // Divisor "ou"
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'ou continue com',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Botão Google
                  OutlinedButton.icon(
                    onPressed: _loginComGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text('Entrar com Google'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                                    const SizedBox(height: 12),

                  // Botão biometria
                  OutlinedButton.icon(
                    onPressed: _loginComBiometria,
                    icon: const Icon(Icons.fingerprint, size: 24),
                    label: const Text('Entrar com biometria'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Link para cadastro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Não tem conta?'),
                      TextButton(
                                   onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RegisterScreen(),
                ),
              );
            },
                        child: const Text('Cadastre-se'),
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