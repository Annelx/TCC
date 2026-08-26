/// Acumula as respostas do usuário ao longo dos 8 passos do onboarding
/// ("primeiros passos"). Cada _step.dart recebe pedaços disso via callback
/// e devolve os dados preenchidos pro OnboardingFlow guardar aqui.
class OnboardingData {
  // Passo 1 - Perfil
  String apelido = '';
  String email = '';
  String? fotoPerfilPath; // caminho local do arquivo escolhido (File.path)

  // Passo 2 - Renda
  double rendaMensal = 0;
  String tipoRenda = ''; // 'fixa' | 'variavel' | 'fixa_variavel'

  // Passo 3 - Gastos fixos
  Map<String, double> gastosFixos = {};

  // Passo 4 - Metas e objetivos
  List<String> objetivosSelecionados = [];
  bool semMetas = false;

  // Passo 5 - Detalhes da meta principal (só preenchido se semMetas == false)
  double? metaValorGuardar;
  double? metaValorAtual;
  double? metaValorTotal; // opcional — valor total da meta, se o usuário informar
  DateTime? metaPrazo;

  // Passo 6 - Principal dificuldade financeira
  List<String> dificuldades = [];

  // Passo 7 - Preferências do app
  String frequenciaRecomendacoes = ''; // 'sempre' | 'semanal' | 'mensal' | 'sob_demanda'
  String nivelIntervencao = ''; // 'leve' | 'moderado' | 'intenso'

  double get totalGastosFixos =>
      gastosFixos.values.fold(0, (soma, valor) => soma + valor);

  /// Monta o body pro POST /onboarding/complete no back-end do Luís
  /// (o upload da foto em si deve ser feito à parte, via multipart, usando
  /// fotoPerfilPath como referência do arquivo local a enviar)
  Map<String, dynamic> toJson() {
    return {
      'apelido': apelido,
      'email': email,
      'renda_mensal': rendaMensal,
      'tipo_renda': tipoRenda,
      'gastos_fixos': gastosFixos,
      'objetivos_selecionados': objetivosSelecionados,
      'sem_metas': semMetas,
      'meta_principal': semMetas
          ? null
          : {
              'valor_guardar': metaValorGuardar,
              'valor_atual': metaValorAtual,
              'valor_total': metaValorTotal,
              'prazo': metaPrazo?.toIso8601String(),
            },
      'dificuldades': dificuldades,
      'frequencia_recomendacoes': frequenciaRecomendacoes,
      'nivel_intervencao': nivelIntervencao,
    };
  }
}