import 'package:flutter/material.dart';
import '../../models/onboarding_data.dart';
import 'perfil_step.dart';
import 'renda_step.dart';
import 'gastos_fixos_step.dart';
import 'metas_step.dart';
import 'detalhes_meta_step.dart';
import 'dificuldade_step.dart';
import 'preferencias_step.dart';
import 'resumo_step.dart';
import '../main_navigation.dart';

/// Widget "pai" dos primeiros passos: controla o PageView com os 8 passos
/// do onboarding e vai acumulando as respostas em [OnboardingData].
///
/// Navegue pra cá depois do login bem-sucedido, ex:
///
/// Navigator.of(context).pushReplacement(
///   MaterialPageRoute(builder: (_) => OnboardingFlow(
///     emailInicial: _emailController.text,
///   )),
/// );
class OnboardingFlow extends StatefulWidget {
  final String apelidoInicial;
  final String emailInicial;

  const OnboardingFlow({
    super.key,
    this.apelidoInicial = '',
    this.emailInicial = '',
  });

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _pageController = PageController();
  final _dados = OnboardingData();

  // Mesmos ids/labels usados no MetasStep — usado só pra exibir o nome
  // bonito da meta escolhida no passo 5.
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

  // Índices das páginas (0-based) — usados no jumpToPage da lógica "sem metas"
  static const _paginaMetas = 3; // passo 4
  static const _paginaDetalhesMeta = 4; // passo 5
  static const _paginaDificuldade = 5; // passo 6

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _irParaProxima() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _voltarPagina() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _concluirOnboarding() {
    // TODO: enviar _dados.toJson() pro back-end (POST /onboarding/complete)
    // antes de navegar, quando o Luís tiver o endpoint pronto.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainNavigation(apelido: _dados.apelido, email: _dados.email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Passo 1 - Perfil
          PerfilStep(
            apelidoInicial: widget.apelidoInicial,
            emailInicial: widget.emailInicial,
            onVoltar: null, // primeiro passo, não tem pra onde voltar
            onContinuar: (apelido, email, foto) {
              _dados.apelido = apelido;
              _dados.email = email;
              _dados.fotoPerfilPath = foto?.path;
              _irParaProxima();
            },
          ),

          // Passo 2 - Renda
          RendaStep(
            rendaInicial: _dados.rendaMensal == 0 ? null : _dados.rendaMensal,
            tipoRendaInicial: _dados.tipoRenda,
            onVoltar: _voltarPagina,
            onContinuar: (renda, tipoRenda) {
              _dados.rendaMensal = renda;
              _dados.tipoRenda = tipoRenda;
              _irParaProxima();
            },
          ),

          // Passo 3 - Gastos fixos
          GastosFixosStep(
            gastosIniciais: _dados.gastosFixos,
            onVoltar: _voltarPagina,
            onContinuar: (gastos) {
              _dados.gastosFixos = gastos;
              _irParaProxima();
            },
          ),

          // Passo 4 - Metas e objetivos
          MetasStep(
            onContinuar: (objetivosSelecionados, semMetas) {
              _dados.objetivosSelecionados = objetivosSelecionados;
              _dados.semMetas = semMetas;

              if (semMetas) {
                // pula direto pro passo 6 (dificuldade)
                _pageController.jumpToPage(_paginaDificuldade);
              } else {
                _irParaProxima();
              }
            },
          ),

          // Passo 5 - Detalhes da meta (só é visto se semMetas == false)
          DetalhesMetaStep(
            nomeMetaPrincipal: _dados.objetivosSelecionados.isNotEmpty
                ? (_labelsObjetivos[_dados.objetivosSelecionados.first] ?? '')
                : '',
            valorGuardarInicial: _dados.metaValorGuardar,
            valorAtualInicial: _dados.metaValorAtual,
            valorTotalInicial: _dados.metaValorTotal,
            prazoInicial: _dados.metaPrazo,
            onVoltar: _voltarPagina,
            onContinuar: (valorGuardar, valorAtual, prazo, valorTotal) {
              _dados.metaValorGuardar = valorGuardar;
              _dados.metaValorAtual = valorAtual;
              _dados.metaValorTotal = valorTotal;
              _dados.metaPrazo = prazo;
              _irParaProxima();
            },
          ),

          // Passo 6 - Principal dificuldade
          DificuldadeStep(
            selecionadasIniciais: _dados.dificuldades,
            onVoltar: _voltarPagina,
            onContinuar: (dificuldades) {
              _dados.dificuldades = dificuldades;
              _irParaProxima();
            },
          ),

          // Passo 7 - Preferências do app
          PreferenciasStep(
            frequenciaInicial: _dados.frequenciaRecomendacoes,
            nivelInicial: _dados.nivelIntervencao,
            onVoltar: _voltarPagina,
            onContinuar: (frequencia, nivel) {
              _dados.frequenciaRecomendacoes = frequencia;
              _dados.nivelIntervencao = nivel;
              _irParaProxima();
            },
          ),

          // Passo 8 - Resumo
          ResumoStep(
            dados: _dados,
            onVoltar: _voltarPagina,
            onConcluir: _concluirOnboarding,
          ),
        ],
      ),
    );
  }
}