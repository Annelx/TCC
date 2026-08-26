import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'change_password_screen.dart';

/// Tela "Segurança": liga/desliga login por biometria e permite trocar senha.
class SegurancaScreen extends StatefulWidget {
  const SegurancaScreen({super.key});

  @override
  State<SegurancaScreen> createState() => _SegurancaScreenState();
}

class _SegurancaScreenState extends State<SegurancaScreen> {
  static const roxo = Color(0xFF8A2BE2);
  final LocalAuthentication _auth = LocalAuthentication();

  bool _biometriaAtiva = false;
  bool _biometriaDisponivel = true;
  bool _verificando = false;

  @override
  void initState() {
    super.initState();
    _verificarDisponibilidade();
  }

  Future<void> _verificarDisponibilidade() async {
    try {
      final disponivel = await _auth.canCheckBiometrics;
      if (!mounted) return;
      setState(() => _biometriaDisponivel = disponivel);
    } catch (_) {
      if (!mounted) return;
      setState(() => _biometriaDisponivel = false);
    }
  }

  Future<void> _alternarBiometria(bool ativar) async {
    if (!_biometriaDisponivel) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometria não disponível neste dispositivo')),
      );
      return;
    }

    setState(() => _verificando = true);

    try {
      final autenticado = await _auth.authenticate(
        localizedReason: ativar
            ? 'Confirme sua biometria para ativar o login rápido'
            : 'Confirme sua biometria para desativar o login rápido',
      );

      if (!mounted) return;

      if (autenticado) {
        setState(() => _biometriaAtiva = ativar);
        // TODO: persistir essa preferência (ex: shared_preferences) e/ou
        // avisar o back-end, quando o Luís tiver isso definido.
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na biometria: $e')),
      );
    } finally {
      if (mounted) setState(() => _verificando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Segurança')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                value: _biometriaAtiva,
                onChanged: _verificando ? null : _alternarBiometria,
                activeColor: roxo,
                secondary: const Icon(Icons.fingerprint, color: roxo),
                title: const Text('Login com biometria', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: Text(
                  _biometriaDisponivel
                      ? 'Use a digital ou reconhecimento facial pra entrar'
                      : 'Não disponível neste dispositivo',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                  );
                },
                leading: const Icon(Icons.lock_outline, color: roxo),
                title: const Text('Alterar senha', style: TextStyle(color: Colors.white, fontSize: 14)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}