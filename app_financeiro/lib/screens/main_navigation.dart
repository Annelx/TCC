import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'metas_screen.dart';
import 'add_meta_screen.dart';
import 'add_transaction_screen.dart';
import 'mais_screen.dart';
import '../services/notification_service.dart';
import '../services/pending_transactions_service.dart';
import '../models/meta_model.dart';
import '../widgets/recent_transactions_section.dart';
import '../widgets/transaction_history_screen.dart';

/// Casca principal do app depois do login/onboarding: mantém a barra de
/// navegação inferior (Início, Transações, Metas, Mais) e o botão central
/// de ação rápida, trocando de tela sem perder o estado de cada aba.
class MainNavigation extends StatefulWidget {
  final String apelido;
  final String? email;

  const MainNavigation({super.key, required this.apelido, this.email});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  static const roxo = Color(0xFF8A2BE2);

  int _abaSelecionada = 0;
  late String _apelido = widget.apelido;
  late String? _email = widget.email;
  String? _telefone;
  String? _fotoPath;
  bool _notificacaoFixaAtiva = true;
  late List<TransacaoMock> _transacoes = List.of(RecentTransactionsSection.mock);

  @override
  void initState() {
    super.initState();
    _ativarNotificacaoFixa();
    _carregarTransacoesPendentes();
  }

  Future<void> _carregarTransacoesPendentes() async {
    final pendentes = await PendingTransactionsService.pegarERemoverTodas();
    if (pendentes.isEmpty || !mounted) return;

    final novas = pendentes.map((registro) {
      // Formato salvo pela notificação: "ENTRADA|50 Alimentação" ou "SAIDA|50 Alimentação"
      final partesRegistro = registro.split('|');
      final isEntrada = partesRegistro.first == 'ENTRADA';
      final texto = partesRegistro.length > 1 ? partesRegistro[1] : partesRegistro.first;

      final partes = texto.trim().split(RegExp(r'\s+'));
      final valor = double.tryParse(partes.first.replaceAll(',', '.')) ?? 0;
      final categoria = partes.length > 1 ? partes.sublist(1).join(' ') : 'Outros';
      return TransacaoMock(
        categoria: categoria,
        icone: Icons.bolt,
        descricao: 'Adicionado pelo atalho',
        valor: valor,
        data: DateTime.now(),
        isEntrada: isEntrada,
      );
    }).toList();

    setState(() => _transacoes.insertAll(0, novas));
  }

  Future<void> _ativarNotificacaoFixa() async {
    await NotificationService.pedirPermissao();
    await NotificationService.mostrarNotificacaoFixa();
  }

  Future<void> _alterarNotificacaoFixa(bool ativar) async {
    if (ativar) {
      await NotificationService.mostrarNotificacaoFixa();
    } else {
      await NotificationService.removerNotificacaoFixa();
    }
    setState(() => _notificacaoFixaAtiva = ativar);
  }

  List<Widget> get _telas => [
        DashboardScreen(apelido: _apelido, transacoes: _transacoes),
        TransactionHistoryScreen(transacoes: _transacoes),
        const MetasScreen(),
        MaisScreen(
          apelido: _apelido,
          email: _email,
          telefone: _telefone,
          fotoPath: _fotoPath,
          notificacaoFixaAtiva: _notificacaoFixaAtiva,
          onAlterarNotificacaoFixa: _alterarNotificacaoFixa,
          onPerfilAtualizado: (resultado) {
            setState(() {
              _apelido = resultado.apelido;
              _email = resultado.email;
              _telefone = resultado.telefone;
              if (resultado.foto != null) _fotoPath = resultado.foto!.path;
            });
          },
        ),
      ];

  void _abrirAcaoRapida() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.swap_vert, color: roxo),
                  title: const Text('Nova transação', style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await Navigator.of(context).push<TransacaoMock>(
                      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                    );
                    // TODO: quando as transações vierem do backend, atualizar
                    // a lista da aba "Transações" aqui após salvar.
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: roxo),
                  title: const Text('Nova meta', style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final novaMeta = await Navigator.of(context).push<Meta>(
                      MaterialPageRoute(builder: (_) => const AddMetaScreen()),
                    );
                    if (novaMeta != null && mounted) {
                      setState(() => _abaSelecionada = 2); // vai pra aba Metas
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _abaSelecionada, children: _telas),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirAcaoRapida,
        backgroundColor: roxo,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF121212),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _itemNav(icone: Icons.home_outlined, label: 'Início', indice: 0),
              _itemNav(icone: Icons.swap_horiz, label: 'Transações', indice: 1),
              const SizedBox(width: 40), // espaço reservado pro FAB
              _itemNav(icone: Icons.flag_outlined, label: 'Metas', indice: 2),
              _itemNav(icone: Icons.more_horiz, label: 'Menu', indice: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemNav({required IconData icone, required String label, required int indice}) {
    final selecionado = _abaSelecionada == indice;
    return InkWell(
      onTap: () => setState(() => _abaSelecionada = indice),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, color: selecionado ? roxo : Colors.white38, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: selecionado ? roxo : Colors.white38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}