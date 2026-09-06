import 'dart:io';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'contas_conectadas_screen.dart';
import 'seguranca_screen.dart';
import 'notificacoes_screen.dart';
import 'recomendacoes_screen.dart';
import 'editar_renda_screen.dart';
import 'editar_gastos_screen.dart';
import 'editar_dificuldade_screen.dart';
import 'central_ajuda_screen.dart';
import 'sobre_screen.dart';
import '../services/notification_service.dart';

/// Aba "Menu": perfil do usuário e opções de configuração (notificações,
/// preferências, contas conectadas, etc).
class MaisScreen extends StatelessWidget {
  final String apelido;
  final String? email;
  final String? telefone;
  final String? fotoPath;
  final bool notificacaoFixaAtiva;
  final ValueChanged<bool> onAlterarNotificacaoFixa;
  final void Function(PerfilAtualizado) onPerfilAtualizado;
  final ValueChanged<String> onEmailAlterado;
  final ValueChanged<String> onTelefoneAlterado;

  const MaisScreen({
    super.key,
    required this.apelido,
    this.email,
    this.telefone,
    this.fotoPath,
    required this.notificacaoFixaAtiva,
    required this.onAlterarNotificacaoFixa,
    required this.onPerfilAtualizado,
    required this.onEmailAlterado,
    required this.onTelefoneAlterado,
  });

  static const roxo = Color(0xFF8A2BE2);

  void _emBreve(BuildContext context, String recurso) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$recurso ainda não foi construído')),
    );
  }

  Future<void> _editarPerfil(BuildContext context) async {
    final resultado = await Navigator.of(context).push<PerfilAtualizado>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          apelidoAtual: apelido,
          emailAtual: email ?? '',
          telefoneAtual: telefone,
          fotoAtualPath: fotoPath,
        ),
      ),
    );
    if (resultado != null) {
      onPerfilAtualizado(resultado);
    }
  }

  Future<void> _sair(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sair da conta', style: TextStyle(color: Colors.white)),
        content: const Text('Tem certeza que deseja sair?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      await NotificationService.removerNotificacaoFixa();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _secao(String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        titulo,
        style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icone,
    required String titulo,
    String? subtitulo,
    required VoidCallback onTap,
    Color? corIcone,
    bool destrutivo = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icone, color: corIcone ?? (destrutivo ? Colors.redAccent : roxo)),
        title: Text(
          titulo,
          style: TextStyle(color: destrutivo ? Colors.redAccent : Colors.white, fontSize: 14),
        ),
        subtitle: subtitulo != null
            ? Text(subtitulo, style: const TextStyle(color: Colors.white38, fontSize: 12))
            : null,
        trailing: destrutivo ? null : const Icon(Icons.chevron_right, color: Colors.white38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Cabeçalho do perfil
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: roxo.withOpacity(0.15),
                  backgroundImage: fotoPath != null ? FileImage(File(fotoPath!)) : null,
                  child: fotoPath == null ? const Icon(Icons.person, color: roxo, size: 32) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(apelido.isNotEmpty ? apelido : 'Usuário',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      if (email != null) ...[
                        const SizedBox(height: 2),
                        Text(email!, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _editarPerfil(context),
                  icon: const Icon(Icons.edit_outlined, color: Colors.white54),
                ),
              ],
            ),

            _secao('CONTA'),
            _item(
              context,
              icone: Icons.person_outline,
              titulo: 'Editar perfil',
              subtitulo: 'Apelido, foto e e-mail',
              onTap: () => _editarPerfil(context),
            ),
            _item(
              context,
              icone: Icons.account_balance_outlined,
              titulo: 'Contas conectadas',
              subtitulo: 'Pluggy Connect',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ContasConectadasScreen()),
                );
              },
            ),
            _item(
              context,
              icone: Icons.fingerprint,
              titulo: 'Segurança',
              subtitulo: 'Biometria, senha, e-mail e telefone',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SegurancaScreen(
                      emailAtual: email ?? '',
                      telefoneAtual: telefone,
                      onEmailAlterado: onEmailAlterado,
                      onTelefoneAlterado: onTelefoneAlterado,
                    ),
                  ),
                );
              },
            ),

            _secao('PREFERÊNCIAS'),
            _item(
              context,
              icone: Icons.notifications_outlined,
              titulo: 'Notificações',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NotificacoesScreen(
                      notificacaoFixaAtiva: notificacaoFixaAtiva,
                      onAlterarNotificacaoFixa: onAlterarNotificacaoFixa,
                    ),
                  ),
                );
              },
            ),
            _item(
              context,
              icone: Icons.tune,
              titulo: 'Recomendações do app',
              subtitulo: 'Frequência e nível de intervenção',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RecomendacoesScreen()),
                );
              },
            ),

            _secao('PERFIL FINANCEIRO'),
            _item(
              context,
              icone: Icons.payments_outlined,
              titulo: 'Renda mensal',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditarRendaScreen()),
                );
              },
            ),
            _item(
              context,
              icone: Icons.home_outlined,
              titulo: 'Gastos fixos',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditarGastosScreen()),
                );
              },
            ),
            _item(
              context,
              icone: Icons.psychology_outlined,
              titulo: 'Dificuldade financeira',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditarDificuldadeScreen()),
                );
              },
            ),

            _secao('SUPORTE'),
            _item(
              context,
              icone: Icons.help_outline,
              titulo: 'Central de ajuda',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CentralAjudaScreen()),
                );
              },
            ),
            _item(
              context,
              icone: Icons.info_outline,
              titulo: 'Sobre o Valora',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SobreScreen()),
                );
              },
            ),

            const SizedBox(height: 12),
            _item(
              context,
              icone: Icons.logout,
              titulo: 'Sair da conta',
              destrutivo: true,
              onTap: () => _sair(context),
            ),
          ],
        ),
      ),
    );
  }
}