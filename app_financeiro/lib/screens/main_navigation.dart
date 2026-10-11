import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'metas_screen.dart';
import 'add_meta_screen.dart';
import 'add_transaction_screen.dart';
import 'chat_ia_screen.dart';
import 'mais_screen.dart';
import '../services/notification_service.dart';
import '../services/transaction_service.dart';
import '../models/meta_model.dart';
import '../services/goal_service.dart';
import '../widgets/recent_transactions_section.dart';
import '../widgets/transaction_history_screen.dart';

/// Casca principal do app depois do login/onboarding: mantém a barra de
/// navegação inferior (Início, Transações, Metas, Menu) e o botão central,
/// cuja ação muda de acordo com a aba selecionada:
/// - Início: abre o Chat com IA
/// - Transações: abre "Nova transação" direto
/// - Metas: abre "Nova meta" direto
/// - Menu: também abre o Chat com IA (padrão)
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
  List<TransacaoMock> _transacoes = [];
  final _transactionService = TransactionService();
  List<Meta> _metas = [];
  final _goalService = GoalService();
  int _dashboardRevision = 0;

  @override
  void initState() {
    super.initState();
    _ativarNotificacaoFixa();
    _carregarTransacoes();
    _carregarMetas();
  }

  Future<void> _carregarTransacoes() async {
    try {
      final items = await _transactionService.getTransactions();
      if (mounted) setState(() { _transacoes = items; _dashboardRevision++; });
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar transações: $error')));
    }
  }

  Future<void> _carregarMetas() async {
    try {
      final metas = await _goalService.list();
      if (mounted) setState(() { _metas = metas; _dashboardRevision++; });
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar metas: $error')),
      );
    }
  }

  Future<void> _editarMeta(Meta meta) async {
    final updated = await Navigator.of(context).push<Meta>(
      MaterialPageRoute(builder: (_) => AddMetaScreen(meta: meta)),
    );
    if (updated != null && mounted) await _carregarMetas();
  }

  Future<void> _excluirMeta(Meta meta) async {
    if (meta.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir meta?'),
        content: Text('Deseja excluir "${meta.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _goalService.delete(meta.id!);
      if (mounted) await _carregarMetas();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir meta: $error')),
      );
    }
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

  Future<void> _abrirNovaTransacao() async {
    final novaTransacao = await Navigator.of(context).push<TransacaoMock>(
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (novaTransacao != null && mounted) {
      await _carregarTransacoes();
    }
  }

  Future<void> _abrirNovaMeta() async {
    final novaMeta = await Navigator.of(context).push<Meta>(
      MaterialPageRoute(builder: (_) => const AddMetaScreen()),
    );
    if (novaMeta != null && mounted) {
      await _carregarMetas();
    }
  }

  void _abrirChatIA() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChatIAScreen()),
    );
  }

  /// Ação do botão central — muda de acordo com a aba selecionada.
  void _acaoBotaoCentral() {
    switch (_abaSelecionada) {
      case 1:
        _abrirNovaTransacao();
        break;
      case 2:
        _abrirNovaMeta();
        break;
      default:
        _abrirChatIA();
    }
  }

  List<Widget> get _telas => [
        DashboardScreen(key: ValueKey(_dashboardRevision), apelido: _apelido, transacoes: _transacoes, metas: _metas),
        TransactionHistoryScreen(transacoes: _transacoes, onChanged: _carregarTransacoes),
        MetasScreen(metas: _metas, onCriarMeta: _abrirNovaMeta, onEditarMeta: _editarMeta, onExcluirMeta: _excluirMeta),
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
              if (resultado.foto != null) _fotoPath = resultado.foto!.path;
            });
          },
          onEmailAlterado: (novoEmail) {
            setState(() => _email = novoEmail);
          },
          onTelefoneAlterado: (novoTelefone) {
            setState(() => _telefone = novoTelefone);
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _abaSelecionada, children: _telas),
      floatingActionButton: FloatingActionButton(
        onPressed: _acaoBotaoCentral,
        backgroundColor: roxo,
        shape: const CircleBorder(),
        child: _abaSelecionada == 1 || _abaSelecionada == 2
            ? const Icon(Icons.add, color: Colors.white)
            : Image.asset(
                'assets/images/valora_logo.png',
                width: 24,
                height: 24,
                color: Colors.white,
                errorBuilder: (context, error, stack) =>
                    const Icon(Icons.smart_toy_outlined, color: Colors.white),
              ),
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