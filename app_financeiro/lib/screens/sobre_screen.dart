import 'package:flutter/material.dart';

/// Tela "Sobre o Valora": informações do app e créditos.
class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  static const roxo = Color(0xFF8A2BE2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o Valora')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            Center(
              child: Image.asset(
                'assets/images/valora_logo_completa.png',
                height: 80,
                errorBuilder: (context, error, stack) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(color: roxo.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.account_balance_wallet, color: roxo, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text('Versão 1.0.0', style: TextStyle(color: Colors.white54, fontSize: 13)),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'O Valora é um app de gestão financeira pessoal com identificação de padrões de '
                'consumo, desenvolvido como Trabalho de Conclusão de Curso em Ciência da '
                'Computação, com o objetivo de usar inteligência artificial para oferecer '
                'recomendações e alertas personalizados sobre a vida financeira do usuário.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Desenvolvido por',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _pessoa('Anne Letícia Xavier de Oliveira', 'Front-end'),
            _pessoa('Luís Henrique de Melo Mendes', 'Back-end, banco de dados e IA'),

            const SizedBox(height: 20),
            const Text('Instituição',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('UNIPÊ — Centro Universitário de João Pessoa',
                style: TextStyle(color: Colors.white70, fontSize: 13)),

            const SizedBox(height: 24),
            const Center(
              child: Text('© 2026 Valora. Todos os direitos reservados.',
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pessoa(String nome, String funcao) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: roxo.withOpacity(0.15),
            child: const Icon(Icons.person, color: roxo, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nome, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              Text(funcao, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}