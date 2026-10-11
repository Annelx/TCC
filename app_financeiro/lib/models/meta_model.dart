class Meta {
  final int? id;
  final String nome;
  final double valorDesejado;
  final double valorAtual;
  final DateTime dataLimite;

  const Meta({
    this.id,
    required this.nome,
    required this.valorDesejado,
    required this.valorAtual,
    required this.dataLimite,
  });

  double get progresso => valorDesejado <= 0 ? 0 : (valorAtual / valorDesejado).clamp(0.0, 1.0);

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    id: json['id'] as int,
    nome: json['name'] as String,
    valorDesejado: double.parse(json['target_amount'].toString()),
    valorAtual: double.parse(json['current_amount'].toString()),
    dataLimite: DateTime.parse(json['deadline'] as String),
  );

  Map<String, dynamic> toJson() => {
    'name': nome,
    'target_amount': valorDesejado.toStringAsFixed(2),
    'current_amount': valorAtual.toStringAsFixed(2),
    'deadline': '${dataLimite.year.toString().padLeft(4, '0')}-${dataLimite.month.toString().padLeft(2, '0')}-${dataLimite.day.toString().padLeft(2, '0')}',
  };
}
