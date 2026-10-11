import 'package:flutter/material.dart';
import '../../models/onboarding_data.dart';
import 'onboarding_step_scaffold.dart';

/// Passo 8 (último) do onboarding: "Tudo pronto!"
/// Mostra um resumo de tudo que foi preenchido nos passos anteriores.
class ResumoStep extends StatelessWidget {
  final OnboardingData dados;
  final VoidCallback onVoltar;
  final VoidCallback? onConcluir;
  final bool salvando;

  const ResumoStep({
    super.key,
    required this.dados,
    required this.onVoltar,
    required this.onConcluir,
    this.salvando = false,
  });

  static const _labelsObjetivos = {
    'reserva_emergencia': 'Criar reserva de emergência',
    'quitar_dividas': 'Quitar dívidas',
    'comprar_imovel': 'Comprar um imóvel',
    'comprar_veiculo': 'Comprar um veículo',
    'fazer_viagem': 'Fazer uma viagem',
    'educacao': 'Estudar / investir em educação',
    'investir': 'Começar a investir',
    'outro': 'Outro objetivo',
  };

  static const _labelsDificuldades = {
    'gastos_desnecessarios': 'Identificar gastos desnecessários',
    'economizar': 'Economizar dinheiro',
    'organizar_gastos': 'Organizar meus gastos',
    'controlar_cartao': 'Controlar cartão de crédito',
    'planejar_metas': 'Planejar minhas metas',
    'controle_financeiro': 'Manter o controle financeiro',
    'sair_dividas': 'Sair das dívidas',
    'outro': 'Outro',
  };

  static const _labelsFrequencia = {
    'sempre': '1x que algo importante acontecer',
    'semanal': '1x por semana',
    'mensal': '1x por mês',
    'sob_demanda': 'Somente quando solicitar',
  };

  static const _labelsNivel = {
    'leve': 'Leve',
    'moderado': 'Moderado',
    'intenso': 'Intenso',
  };

  static const _meses = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  Widget _item(BuildContext context, IconData icone, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: OnboardingStepScaffold.roxo, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 2),
                Text(valor, style: const TextStyle(color: Colors.white, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final objetivosTexto = dados.objetivosSelecionados
        .map((id) => _labelsObjetivos[id] ?? id)
        .join(', ');

    final dificuldadesTexto = dados.dificuldades
        .map((id) => _labelsDificuldades[id] ?? id)
        .join(', ');

    return OnboardingStepScaffold(
      icone: Icons.celebration_outlined,
      titulo: 'Tudo pronto! 🎉',
      subtitulo: 'Esse é o resumo do seu perfil financeiro.',
      passoAtual: 7,
      totalPassos: 7,
      onVoltar: onVoltar,
      footer: ElevatedButton(
        onPressed: onConcluir,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: salvando
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Concluir e começar'),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _item(context, Icons.payments_outlined, 'Renda média mensal',
                'R\$ ${dados.rendaMensal.toStringAsFixed(2)}'),
            _item(context, Icons.home_outlined, 'Gastos fixos mensais',
                'R\$ ${dados.totalGastosFixos.toStringAsFixed(2)}'),
            _item(context, Icons.flag_outlined, 'Objetivos selecionados',
                dados.semMetas
                    ? 'Nenhuma meta definida ainda — você pode criar quando quiser'
                    : (objetivosTexto.isEmpty ? '—' : objetivosTexto)),
            if (!dados.semMetas && dados.metaValorGuardar != null)
              _item(
                context,
                Icons.savings_outlined,
                'Meta principal',
                '${_labelsObjetivos[dados.objetivosSelecionados.isNotEmpty ? dados.objetivosSelecionados.first : ''] ?? ''}\n'
                    'R\$ ${dados.metaValorGuardar!.toStringAsFixed(2)}'
                    '${dados.metaPrazo != null ? ' até ${_meses[dados.metaPrazo!.month - 1]}/${dados.metaPrazo!.year}' : ''}',
              ),
            _item(context, Icons.warning_amber_outlined, 'Principal dificuldade',
                dificuldadesTexto.isEmpty ? '—' : dificuldadesTexto),
            _item(context, Icons.tune, 'Preferências',
                'Recomendações ${_labelsFrequencia[dados.frequenciaRecomendacoes] ?? '—'}\n'
                    'Nível ${_labelsNivel[dados.nivelIntervencao] ?? '—'}'),
          ],
        ),
      ),
    );
  }
}