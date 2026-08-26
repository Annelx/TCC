import 'package:flutter/material.dart';
import '../models/meta_model.dart';
import 'add_meta_screen.dart';

/// Tela "Metas" (aba do menu inferior): lista as metas do usuário com
/// barra de progresso, e um botão flutuante "+" pra criar uma nova.
///
/// Por enquanto guarda as metas só em memória (mock). Quando o Luís tiver
/// o endpoint pronto (GET /metas, POST /metas), trocar o estado local por
/// uma chamada real — o TODO abaixo marca onde entra o POST.
class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  static const roxo = Color(0xFF8A2BE2);
  static const _meses = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  final List<Meta> _metas = [];

  Future<void> _abrirNovaMeta() async {
    final novaMeta = await Navigator.of(context).push<Meta>(
      MaterialPageRoute(builder: (_) => const AddMetaScreen()),
    );
    if (novaMeta != null) {
      // TODO: enviar novaMeta.toJson() pro back-end (POST /metas)
      setState(() => _metas.add(novaMeta));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metas')),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirNovaMeta,
        backgroundColor: roxo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: _metas.isEmpty
            ? _EstadoVazio(onCriar: _abrirNovaMeta)
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _metas.length,
                itemBuilder: (context, index) {
                  final meta = _metas[index];
                  final progresso = meta.progresso;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: roxo.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.flag_outlined, color: roxo, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(meta.nome,
                                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Até ${_meses[meta.dataLimite.month - 1]} de ${meta.dataLimite.year}',
                                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${(progresso * 100).toInt()}%',
                              style: const TextStyle(color: roxo, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progresso,
                            minHeight: 8,
                            backgroundColor: const Color(0xFF2A2A2A),
                            valueColor: const AlwaysStoppedAnimation(roxo),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('R\$ ${meta.valorAtual.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('R\$ ${meta.valorDesejado.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  static const roxo = Color(0xFF8A2BE2);
  final VoidCallback onCriar;

  const _EstadoVazio({required this.onCriar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: roxo.withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.track_changes, color: roxo, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'Você ainda não tem metas',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crie sua primeira meta e acompanhe seu progresso por aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onCriar,
              child: const Text('Criar meta'),
            ),
          ],
        ),
      ),
    );
  }
}