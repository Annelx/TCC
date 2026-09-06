import 'package:flutter/material.dart';
import '../models/conta_bancaria_model.dart';
import 'conectar_banco_screen.dart';

/// Tela "Contas conectadas" (Pluggy Connect): lista as contas bancárias
/// já conectadas e permite adicionar uma nova via Pluggy Connect.
class ContasConectadasScreen extends StatefulWidget {
  const ContasConectadasScreen({super.key});

  @override
  State<ContasConectadasScreen> createState() => _ContasConectadasScreenState();
}

class _ContasConectadasScreenState extends State<ContasConectadasScreen> {
  static const roxo = Color(0xFF8A2BE2);

  final List<ContaBancaria> _contas = [];

  Future<void> _abrirConectarBanco() async {
    final novaConta = await Navigator.of(context).push<ContaBancaria>(
      MaterialPageRoute(builder: (_) => const ConectarBancoScreen()),
    );
    if (novaConta != null) {
      // TODO: quando integrar de verdade, o back-end já vai ter salvo a
      // conta — aqui só precisa recarregar a lista via GET /contas-conectadas
      setState(() => _contas.add(novaConta));
    }
  }

  void _desconectar(ContaBancaria conta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Desconectar banco', style: TextStyle(color: Colors.white)),
        content: Text(
          'Tem certeza que deseja desconectar ${conta.nomeBanco}? As transações já importadas continuam no seu histórico.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: chamar o back-end pra revogar o consentimento (DELETE /contas-conectadas/:id)
              setState(() => _contas.remove(conta));
              Navigator.of(context).pop();
            },
            child: const Text('Desconectar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')} às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contas conectadas')),
      body: SafeArea(
        child: _contas.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(color: roxo.withOpacity(0.15), shape: BoxShape.circle),
                        child: const Icon(Icons.account_balance_outlined, color: roxo, size: 36),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Nenhum banco conectado',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Conecte suas contas via Pluggy Connect e suas transações entram automaticamente.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _abrirConectarBanco,
                        icon: const Icon(Icons.add),
                        label: const Text('Conectar banco'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ..._contas.map((conta) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: roxo.withOpacity(0.15), shape: BoxShape.circle),
                            child: const Icon(Icons.account_balance, color: roxo, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(conta.nomeBanco,
                                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(conta.tipoConta, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(
                                  'Sincronizado em ${_formatarData(conta.ultimaSincronizacao)}',
                                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _desconectar(conta),
                            icon: const Icon(Icons.link_off, color: Colors.white38, size: 20),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _abrirConectarBanco,
                    icon: const Icon(Icons.add),
                    label: const Text('Conectar outro banco'),
                  ),
                ],
              ),
      ),
    );
  }
}