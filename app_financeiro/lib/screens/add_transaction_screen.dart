import 'package:flutter/material.dart';
import '../widgets/recent_transactions_section.dart';

/// Tela "Nova transação" / "Editar transação". Se [transacaoParaEditar] for
/// passada, o formulário já vem preenchido com os dados dela (modo edição);
/// caso contrário, abre em branco (modo criação).
///
/// Devolve a transação criada/editada pra quem chamou, via Navigator.pop:
///
/// final resultado = await Navigator.of(context).push<TransacaoMock>(
///   MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
/// );
class AddTransactionScreen extends StatefulWidget {
  final TransacaoMock? transacaoParaEditar;

  const AddTransactionScreen({super.key, this.transacaoParaEditar});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  static const roxo = Color(0xFF8A2BE2);
  static const _verde = Color(0xFF4CD97B);
  static const _vermelho = Color(0xFFFF6B6B);

  static const _meses = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  static const _categorias = [
    ('Moradia', Icons.home_outlined),
    ('Alimentação', Icons.restaurant_outlined),
    ('Transporte', Icons.directions_car_outlined),
    ('Saúde', Icons.favorite_outline),
    ('Educação', Icons.school_outlined),
    ('Lazer', Icons.movie_outlined),
    ('Salário', Icons.attach_money),
    ('Outros', Icons.more_horiz),
  ];

  final _formKey = GlobalKey<FormState>();
  late final _descricaoController = TextEditingController(
    text: widget.transacaoParaEditar?.descricao ?? '',
  );
  late final _valorController = TextEditingController(
    text: widget.transacaoParaEditar != null
        ? widget.transacaoParaEditar!.valor.toStringAsFixed(2)
        : '',
  );

  late bool _isEntrada = widget.transacaoParaEditar?.isEntrada ?? false;
  late String _categoriaSelecionada =
      widget.transacaoParaEditar?.categoria ?? _categorias.first.$1;
  late DateTime _data = widget.transacaoParaEditar?.data ?? DateTime.now();
  bool _salvando = false;

  bool get _modoEdicao => widget.transacaoParaEditar != null;

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  double _parse(String texto) {
    final normalizado = texto.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalizado) ?? 0;
  }

  IconData _iconeDaCategoria(String categoria) {
    return _categorias
        .firstWhere((c) => c.$1 == categoria, orElse: () => _categorias.last)
        .$2;
  }

  Future<void> _escolherData() async {
    final selecionada = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
      helpText: 'Data da transação',
    );
    if (selecionada != null) {
      setState(() => _data = selecionada);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final transacao = TransacaoMock(
      categoria: _categoriaSelecionada,
      icone: _iconeDaCategoria(_categoriaSelecionada),
      descricao: _descricaoController.text.trim(),
      valor: _parse(_valorController.text),
      data: _data,
      isEntrada: _isEntrada,
      // Se está editando uma transação que já veio do Pluggy Connect, mantém
      // a origem e o banco originais — só uma criada do zero aqui é 'manual'.
      origem: widget.transacaoParaEditar?.origem ?? OrigemTransacao.manual,
      nomeBanco: widget.transacaoParaEditar?.nomeBanco,
    );

    // TODO: enviar a transação pro back-end quando o Luís tiver o endpoint
    // pronto — POST /transacoes (criação) ou PUT /transacoes/:id (edição).
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() => _salvando = false);
    Navigator.of(context).pop(transacao);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_modoEdicao ? 'Editar transação' : 'Nova transação')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Toggle Entrada / Saída
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _botaoTipo(
                          label: 'Saída',
                          icone: Icons.arrow_downward,
                          cor: _vermelho,
                          selecionado: !_isEntrada,
                          onTap: () => setState(() => _isEntrada = false),
                        ),
                      ),
                      Expanded(
                        child: _botaoTipo(
                          label: 'Entrada',
                          icone: Icons.arrow_upward,
                          cor: _verde,
                          selecionado: _isEntrada,
                          onTap: () => setState(() => _isEntrada = true),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _valorController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 20),
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    prefixText: 'R\$ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o valor';
                    }
                    if (_parse(value) <= 0) {
                      return 'Valor inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Ex: Supermercado Extra',
                    prefixIcon: Icon(Icons.edit_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe uma descrição';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: _escolherData,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      '${_data.day.toString().padLeft(2, '0')} de ${_meses[_data.month - 1]} de ${_data.year}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text('Categoria', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _categorias.map((categoria) {
                    final (nome, icone) = categoria;
                    final selecionado = _categoriaSelecionada == nome;
                    return GestureDetector(
                      onTap: () => setState(() => _categoriaSelecionada = nome),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: selecionado ? roxo.withOpacity(0.25) : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selecionado ? roxo : const Color(0xFF2A2A2A),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icone, size: 16, color: selecionado ? roxo : Colors.white54),
                            const SizedBox(width: 6),
                            Text(nome, style: TextStyle(color: selecionado ? Colors.white : Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _salvando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_modoEdicao ? 'Salvar alterações' : 'Salvar transação'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _botaoTipo({
    required String label,
    required IconData icone,
    required Color cor,
    required bool selecionado,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selecionado ? cor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selecionado ? Border.all(color: cor, width: 1.5) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 18, color: selecionado ? cor : Colors.white54),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: selecionado ? cor : Colors.white54, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}