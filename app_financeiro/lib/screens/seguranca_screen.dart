import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'change_password_screen.dart';
import 'change_email_screen.dart';
import 'change_phone_screen.dart';

/// Tela "Segurança": liga/desliga login por biometria, e permite trocar
/// senha, e-mail e telefone (esses dois últimos exigem confirmar o valor
/// atual antes de liberar a alteração).
class SegurancaScreen extends StatefulWidget {
  final String emailAtual;
  final String? telefoneAtual;
  final ValueChanged<String> onEmailAlterado;
  final ValueChanged<String> onTelefoneAlterado;

  const SegurancaScreen({
    super.key,
    required this.emailAtual,
    this.telefoneAtual,
    required this.onEmailAlterado,
    required this.onTelefoneAlterado,
  });

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

  Future<void> _alterarEmail() async {
    final novoEmail = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => ChangeEmailScreen(emailAtual: widget.emailAtual)),
    );
    if (novoEmail != null) {
      widget.onEmailAlterado(novoEmail);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail alterado com sucesso')),
        );
      }
    }
  }

  Future<void> _alterarTelefone() async {
    final novoTelefone = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => ChangePhoneScreen(telefoneAtual: widget.telefoneAtual ?? '')),
    );
    if (novoTelefone != null) {
      widget.onTelefoneAlterado(novoTelefone);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telefone alterado com sucesso')),
        );
      }
    }
  }

  Widget _item({
    required IconData icone,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icone, color: roxo),
        title: Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
              margin: const EdgeInsets.only(bottom: 12),
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
            _item(icone: Icons.lock_outline, titulo: 'Alterar senha', onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            }),
            _item(icone: Icons.email_outlined, titulo: 'Alterar e-mail', onTap: _alterarEmail),
            _item(icone: Icons.phone_outlined, titulo: 'Alterar telefone', onTap: _alterarTelefone),
          ],
        ),
      ),
    );
  }
}