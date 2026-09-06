import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tela "Central de ajuda": perguntas frequentes sobre o uso do app.
class CentralAjudaScreen extends StatelessWidget {
  const CentralAjudaScreen({super.key});

  static const roxo = Color(0xFF8A2BE2);

  static const _perguntas = [
    (
      'Como adiciono uma transação manualmente?',
      'Toque no botão "+" na barra inferior e escolha "Nova transação", ou acesse a aba Transações e use o botão de adicionar. Você também pode tocar em qualquer transação da lista para editá-la.',
    ),
    (
      'O que é o Pluggy Connect e como conecto meu banco?',
      'O Pluggy Connect permite importar automaticamente suas transações bancárias, com sua autorização. Vá em Menu > Contas conectadas e siga o passo a passo para conectar seu banco com segurança.',
    ),
    (
      'Como crio uma meta financeira?',
      'Na aba Metas, toque no botão "+" para criar uma nova meta, informando o nome, o valor desejado, quanto você já possui e o prazo.',
    ),
    (
      'Posso mudar minhas preferências de recomendações depois do cadastro?',
      'Sim! Vá em Menu > Recomendações do app para ajustar a frequência das notificações e o nível de intervenção a qualquer momento.',
    ),
    (
      'Como ativo a biometria para entrar no app?',
      'Vá em Menu > Segurança e ative a opção "Login com biometria". Você vai precisar confirmar com sua digital ou reconhecimento facial.',
    ),
    (
      'Meus dados financeiros estão seguros?',
      'Sim. Suas informações são protegidas e você pode desconectar contas bancárias ou alterar suas configurações de segurança a qualquer momento pelo Menu.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Central de ajuda')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Perguntas frequentes',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ..._perguntas.map((item) {
              final (pergunta, resposta) = item;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    iconColor: roxo,
                    collapsedIconColor: Colors.white54,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    title: Text(pergunta,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(resposta, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _abrirEmailSuporte(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: roxo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.email_outlined, color: roxo, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Não encontrou o que precisava?',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'suporte.valora@gmail.com',
                            style: TextStyle(color: roxo, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white38, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirEmailSuporte(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'suporte.valora@gmail.com',
      query: 'subject=Suporte Valora',
    );
    final abriu = await launchUrl(uri);
    if (!abriu && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o app de e-mail')),
      );
    }
  }
}