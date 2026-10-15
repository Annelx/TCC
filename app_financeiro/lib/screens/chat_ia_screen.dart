import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../services/ai_service.dart';

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
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiService _service = AiService();

  bool _enviando = false;
  final List<_Mensagem> _mensagens = [
    const _Mensagem(
      'Olá! Sou o assistente financeiro do Valora. '
      'Pergunte sobre suas despesas, receitas, categorias '
      'ou metas deste mês.',
      false,
    ),
  ];

  void _rolar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _enviar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _enviando) return;
    _controller.clear();
    setState(() {
      _enviando = true;
      _mensagens.add(_Mensagem(texto, true));
    });
    _rolar();
    try {
      final result = await _service.ask(texto);
      if (!mounted) return;
      final modo = result['mode'] == 'gemini' ? 'Gemini' : 'Análise local';
      final resposta = result['reply']?.toString() ?? '';
      setState(() {
        _mensagens.add(
          _Mensagem('$resposta\n\n$modo · orientação educativa', false),
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _mensagens.add(
          const _Mensagem(
            'Não foi possível consultar suas finanças agora. '
            'Confira a conexão com o backend e tente novamente.',
            false,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
        _rolar();
      }
    }
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
                    alignment: m.doUsuario
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.78,
                      ),
                      decoration: BoxDecoration(
                        color: m.doUsuario ? roxo : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: m.doUsuario
                          ? Text(
                              m.texto,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            )
                          : MarkdownBody(
                              data: m.texto,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                p: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                strong: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                em: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                                listBullet: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                h1: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                h2: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                h3: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                blockSpacing: 10,
                                listIndent: 20,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),

            if (_enviando)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: LinearProgressIndicator(),
              ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_enviando,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviar(),
                      decoration: const InputDecoration(
                        hintText: 'Pergunte algo sobre suas finanças...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _enviando ? null : _enviar,
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
