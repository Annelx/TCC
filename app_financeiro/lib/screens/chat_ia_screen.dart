import 'package:flutter/material.dart';

/// Tela "Chat com IA" — conversa com o assistente financeiro do Valora.
///
/// Ainda não conectada a nenhum modelo de IA de verdade (essa é a parte
/// central do TCC, a ser construída). Por enquanto simula uma resposta
/// simples, só pra manter a experiência de tela pronta.
class ChatIAScreen extends StatefulWidget {
  const ChatIAScreen({super.key});

  @override
  State<ChatIAScreen> createState() => _ChatIAScreenState();
}

class _Mensagem {
  final String texto;
  final bool doUsuario;
  const _Mensagem(this.texto, this.doUsuario);
}

class _ChatIAScreenState extends State<ChatIAScreen> {
  static const roxo = Color(0xFF8A2BE2);

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_Mensagem> _mensagens = [
    const _Mensagem(
      'Olá! Eu sou o assistente do Valora. Em breve vou poder analisar seus '
      'gastos e te dar recomendações personalizadas. Por enquanto, essa é '
      'só uma prévia da tela de chat 🙂',
      false,
    ),
  ];

  void _enviar() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _mensagens.add(_Mensagem(texto, true));
      _mensagens.add(const _Mensagem(
        'Essa funcionalidade ainda está sendo desenvolvida — em breve vou conseguir responder de verdade!',
        false,
      ));
    });
    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy_outlined, color: roxo, size: 22),
            SizedBox(width: 8),
            Text('Assistente Valora'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _mensagens.length,
                itemBuilder: (context, index) {
                  final m = _mensagens[index];
                  return Align(
                    alignment: m.doUsuario ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: m.doUsuario ? roxo : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(m.texto, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _enviar(),
                      decoration: const InputDecoration(
                        hintText: 'Pergunte algo sobre suas finanças...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _enviar,
                    style: IconButton.styleFrom(backgroundColor: roxo),
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}