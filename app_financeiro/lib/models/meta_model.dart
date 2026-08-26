/// Modelo de uma meta financeira criada pelo usuário (ex: "Viagem para o
/// nordeste", "Reserva de emergência"). Quando o Luís tiver o endpoint de
/// metas pronto, esse modelo deve bater com o formato retornado pela API
/// (adicionar campo `id` vindo do backend, por exemplo).
class Meta {
  final String nome;
  final double valorDesejado;
  final double valorAtual;
  final DateTime dataLimite;

  const Meta({
    required this.nome,
    required this.valorDesejado,
    required this.valorAtual,
    required this.dataLimite,
  });

  double get progresso =>
      valorDesejado <= 0 ? 0 : (valorAtual / valorDesejado).clamp(0, 1);

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'valor_desejado': valorDesejado,
      'valor_atual': valorAtual,
      'data_limite': dataLimite.toIso8601String(),
    };
  }
}