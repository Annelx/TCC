import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'new_password_screen.dart';

class ResetVerifyCodeScreen extends StatefulWidget {
  final String email;

  const ResetVerifyCodeScreen({super.key, required this.email});

  @override
  State<ResetVerifyCodeScreen> createState() => _ResetVerifyCodeScreenState();
}

class _ResetVerifyCodeScreenState extends State<ResetVerifyCodeScreen> {
  static const roxo = Color(0xFF8A2BE2);
  static const quantidadeDigitos = 6;

  final List<TextEditingController> _controllers =
      List.generate(quantidadeDigitos, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(quantidadeDigitos, (_) => FocusNode());

  bool _carregando = false;
  String? _mensagemErro;
  int _segundosParaReenviar = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _iniciarContagemReenvio();
  }

  void _iniciarContagemReenvio() {
    _segundosParaReenviar = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosParaReenviar <= 1) {
        timer.cancel();
        setState(() => _segundosParaReenviar = 0);
      } else {
        setState(() => _segundosParaReenviar--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  String get _codigoDigitado => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < quantidadeDigitos - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_codigoDigitado.length == quantidadeDigitos) {
      _confirmarCodigo();
    }
  }

  void _confirmarCodigo() async {
    if (_codigoDigitado.length < quantidadeDigitos) {
      setState(() => _mensagemErro = 'Digite o código completo');
      return;
    }

    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    // MOCK: aqui vai a chamada real ao back-end
    // (POST /auth/verify-reset-code, com { email, codigo })
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _carregando = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => NewPasswordScreen(
          email: widget.email,
          codigo: _codigoDigitado,
        ),
      ),
    );
  }

  void _reenviarCodigo() {
    if (_segundosParaReenviar > 0) return;

    // TODO: chamar o back-end para reenviar o código de verdade
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código reenviado (mock)!')),
    );
    _iniciarContagemReenvio();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.mark_email_read_outlined,
                    size: 56, color: roxo),
                const SizedBox(height: 16),
                Text(
                  'Verifique seu e-mail',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enviamos um código de 6 dígitos para\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(quantidadeDigitos, (index) {
                    return SizedBox(
                      width: 44,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 20),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => _onDigitChanged(index, value),
                      ),
                    );
                  }),
                ),
                if (_mensagemErro != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _mensagemErro!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _carregando ? null : _confirmarCodigo,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _carregando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirmar'),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed:
                        _segundosParaReenviar > 0 ? null : _reenviarCodigo,
                    child: Text(
                      _segundosParaReenviar > 0
                          ? 'Reenviar código em ${_segundosParaReenviar}s'
                          : 'Reenviar código',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}