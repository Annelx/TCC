import 'package:flutter/material.dart';
import '../models/meta_model.dart';
import '../services/goal_service.dart';

/// Tela "Nova meta" — usuário preenche nome, valor desejado, valor atual e
/// data limite. Ao salvar, devolve um [Meta] pra tela anterior via
/// Navigator.pop(meta).
///
/// Uso (na tela que lista as metas, ex: metas_screen.dart):
///
/// final novaMeta = await Navigator.of(context).push<Meta>(
///   MaterialPageRoute(builder: (_) => const AddMetaScreen()),
/// );
/// if (novaMeta != null) {
///   setState(() => _metas.add(novaMeta));
///   // TODO: enviar novaMeta.toJson() pro back-end (POST /metas)
/// }
class AddMetaScreen extends StatefulWidget {
  final Meta? meta;
  const AddMetaScreen({super.key, this.meta});

  @override
  State<AddMetaScreen> createState() => _AddMetaScreenState();
}

class _AddMetaScreenState extends State<AddMetaScreen> {
  static const roxo = Color(0xFF8A2BE2);
  static const _meses = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorDesejadoController = TextEditingController();
  final _valorAtualController = TextEditingController(text: '0');
  DateTime? _dataLimite;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final meta = widget.meta;
    if (meta != null) {
      _nomeController.text = meta.nome;
      _valorDesejadoController.text = meta.valorDesejado.toStringAsFixed(2);
      _valorAtualController.text = meta.valorAtual.toStringAsFixed(2);
      _dataLimite = meta.dataLimite;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorDesejadoController.dispose();
    _valorAtualController.dispose();
    super.dispose();
  }

  double _parse(String texto) {
    final normalizado = texto.contains(',') ? texto.replaceAll('.', '').replaceAll(',', '.') : texto;
    return double.tryParse(normalizado) ?? 0;
  }

  Future<void> _escolherData() async {
    final selecionada = await showDatePicker(
      context: context,
      initialDate: _dataLimite ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 15)),
      helpText: 'Data limite da meta',
    );
    if (selecionada != null) {
      setState(() => _dataLimite = selecionada);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataLimite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha uma data limite para a meta')),
      );
      return;
    }

    final target = _parse(_valorDesejadoController.text);
    final current = _parse(_valorAtualController.text);
    if (current < 0 || current > target) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O valor atual deve ficar entre zero e o valor desejado')),
      );
      return;
    }
    setState(() => _salvando = true);

    final meta = Meta(
      id: widget.meta?.id,
      nome: _nomeController.text.trim(),
      valorDesejado: _parse(_valorDesejadoController.text),
      valorAtual: _parse(_valorAtualController.text),
      dataLimite: _dataLimite!,
    );

    try {
      final saved = await GoalService().save(meta);
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível salvar a meta: $error')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.meta == null ? 'Nova meta' : 'Editar meta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: roxo.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.track_changes, color: roxo, size: 32),
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da meta',
                    hintText: 'Ex: Viagem para o nordeste',
                    prefixIcon: Icon(Icons.flag_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe um nome para a meta';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _valorDesejadoController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Valor desejado',
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _valorAtualController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Valor atual',
                          prefixText: 'R\$ ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe 0 se ainda não tem nada';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: _escolherData,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data limite',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _dataLimite != null
                          ? '${_meses[_dataLimite!.month - 1]} / ${_dataLimite!.year}'
                          : 'Selecionar data',
                      style: TextStyle(
                        color: _dataLimite != null ? Colors.white : Colors.white38,
                      ),
                    ),
                  ),
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
                      : const Text('Salvar meta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}