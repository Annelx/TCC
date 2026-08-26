import 'package:flutter/material.dart';
import 'recent_transactions_section.dart';
import '../screens/add_transaction_screen.dart';

/// Tela de histórico completo de transações, com busca por texto e
/// filtro por período (mês/ano).
class TransactionHistoryScreen extends StatefulWidget {
  final List<TransacaoMock> transacoes;

  const TransactionHistoryScreen({super.key, required this.transacoes});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  static const roxo = Color(0xFF8A2BE2);
  static const _meses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  final _buscaController = TextEditingController();
  String _busca = '';
  int? _mesFiltro; // null = todos os meses
  int _anoFiltro = DateTime.now().year;

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  List<TransacaoMock> get _transacoesFiltradas {
    return widget.transacoes.where((t) {
      final bateBusca = _busca.isEmpty ||
          t.descricao.toLowerCase().contains(_busca.toLowerCase()) ||
          t.categoria.toLowerCase().contains(_busca.toLowerCase());

      final bateMes = _mesFiltro == null || t.data.month == _mesFiltro;
      final bateAno = t.data.year == _anoFiltro;

      return bateBusca && bateMes && bateAno;
    }).toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  Future<void> _abrirFiltroPeriodo() async {
    int? mesSelecionado = _mesFiltro;
    int anoSelecionado = _anoFiltro;

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Filtrar por período',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ano: $anoSelecionado', style: const TextStyle(color: Colors.white70)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => setModalState(() => anoSelecionado--),
                            icon: const Icon(Icons.chevron_left, color: Colors.white70),
                          ),
                          IconButton(
                            onPressed: anoSelecionado < DateTime.now().year
                                ? () => setModalState(() => anoSelecionado++)
                                : null,
                            icon: const Icon(Icons.chevron_right, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Todos os meses'),
                        selected: mesSelecionado == null,
                        onSelected: (_) => setModalState(() => mesSelecionado = null),
                        selectedColor: roxo,
                        labelStyle: TextStyle(
                          color: mesSelecionado == null ? Colors.white : Colors.white70,
                        ),
                        backgroundColor: const Color(0xFF1A1A1A),
                      ),
                      ...List.generate(12, (i) {
                        final mes = i + 1;
                        return ChoiceChip(
                          label: Text(_meses[i].substring(0, 3)),
                          selected: mesSelecionado == mes,
                          onSelected: (_) => setModalState(() => mesSelecionado = mes),
                          selectedColor: roxo,
                          labelStyle: TextStyle(
                            color: mesSelecionado == mes ? Colors.white : Colors.white70,
                          ),
                          backgroundColor: const Color(0xFF1A1A1A),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _mesFiltro = mesSelecionado;
                        _anoFiltro = anoSelecionado;
                      });
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: roxo,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Aplicar filtro'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _transacoesFiltradas;
    final filtroAtivo = _mesFiltro != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de transações')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _buscaController,
                      onChanged: (value) => setState(() => _busca = value),
                      decoration: const InputDecoration(
                        hintText: 'Buscar por descrição ou categoria',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    children: [
                      IconButton.filledTonal(
                        onPressed: _abrirFiltroPeriodo,
                        icon: const Icon(Icons.filter_list),
                      ),
                      if (filtroAtivo)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: roxo, shape: BoxShape.circle),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    _mesFiltro != null ? '${_meses[_mesFiltro! - 1]} de $_anoFiltro' : 'Ano de $_anoFiltro',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const Spacer(),
                  Text('${filtradas.length} transações', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: filtradas.isEmpty
                  ? const Center(
                      child: Text('Nenhuma transação encontrada', style: TextStyle(color: Colors.white38)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtradas.length,
                      itemBuilder: (context, index) {
                        final t = filtradas[index];
                        final cor = t.isEntrada ? const Color(0xFF4CD97B) : const Color(0xFFFF6B6B);
                        final sinal = t.isEntrada ? '+' : '-';
                        final viaOpenFinance = t.origem == OrigemTransacao.openFinance;

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.of(context).push<TransacaoMock>(
                              MaterialPageRoute(
                                builder: (_) => AddTransactionScreen(transacaoParaEditar: t),
                              ),
                            );
                            // TODO: quando vier do backend, atualizar a lista
                            // com o resultado (transação editada) aqui.
                          },
                          child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: roxo.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(t.icone, color: roxo, size: 20),
                                  ),
                                  if (viaOpenFinance)
                                    Positioned(
                                      bottom: -2,
                                      right: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF1A1A1A),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.account_balance, size: 12, color: Colors.white54),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.descricao, style: const TextStyle(color: Colors.white, fontSize: 14)),
                                    const SizedBox(height: 2),
                                    Text(
                                      viaOpenFinance
                                          ? '${t.categoria} · ${t.nomeBanco} · ${_formatarData(t.data)}'
                                          : '${t.categoria} · ${_formatarData(t.data)}',
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '$sinal R\$ ${t.valor.toStringAsFixed(2)}',
                                style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}