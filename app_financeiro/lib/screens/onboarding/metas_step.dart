import 'package:flutter/material.dart';

/// Passo 4 do onboarding: "Metas e objetivos"
///
/// Uso esperado (dentro do PageView do onboarding):
///
/// MetasStep(
///   onContinuar: (objetivosSelecionados, semMetas) {
///     if (semMetas) {
///       _pageController.jumpToPage(5); // pula direto pro passo 6
///     } else {
///       _pageController.nextPage(
///         duration: const Duration(milliseconds: 300),
///         curve: Curves.easeInOut,
///       );
///     }
///   },
/// )
class MetasStep extends StatefulWidget {
  final void Function(List<String> objetivosSelecionados, bool semMetas)
      onContinuar;

  const MetasStep({super.key, required this.onContinuar});

  @override
  State<MetasStep> createState() => _MetasStepState();
}

class _MetasStepState extends State<MetasStep> {
  static const Color corFundo = Color(0xFF000000);
  static const Color corRoxa = Color(0xFF8A2BE2);
  static const Color corCardInativo = Color(0xFF1A1A1A);
  static const Color corTextoSecundario = Color(0xFFAAAAAA);

  final List<_Objetivo> _objetivos = [
    _Objetivo('reserva_emergencia', 'Criar reserva de emergência'),
    _Objetivo('quitar_dividas', 'Quitar dívidas'),
    _Objetivo('comprar_imovel', 'Comprar um imóvel'),
    _Objetivo('comprar_veiculo', 'Comprar um veículo'),
    _Objetivo('fazer_viagem', 'Fazer uma viagem'),
    _Objetivo('educacao', 'Estudar / investir em educação'),
    _Objetivo('investir', 'Começar a investir'),
    _Objetivo('outro', 'Outro objetivo'),
  ];

  final Set<String> _objetivosSelecionados = {};
  bool _semMetasSelecionado = false;

  void _toggleObjetivo(String id) {
    setState(() {
      // Selecionar qualquer objetivo normal cancela "sem metas"
      _semMetasSelecionado = false;

      if (_objetivosSelecionados.contains(id)) {
        _objetivosSelecionados.remove(id);
      } else {
        _objetivosSelecionados.add(id);
      }
    });
  }

  void _toggleSemMetas() {
    setState(() {
      _semMetasSelecionado = !_semMetasSelecionado;
      if (_semMetasSelecionado) {
        // Seleção exclusiva: limpa os objetivos normais
        _objetivosSelecionados.clear();
      }
    });
  }

  bool get _podeContinuar =>
      _objetivosSelecionados.isNotEmpty || _semMetasSelecionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Ícone circular no topo (padrão das outras telas)
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: corRoxa,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.track_changes,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Você possui algum objetivo financeiro?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecione um ou mais objetivos que você deseja conquistar.',
                style: TextStyle(color: corTextoSecundario, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Lista de objetivos
              Expanded(
                child: ListView(
                  children: [
                    ..._objetivos.map((objetivo) {
                      final selecionado =
                          _objetivosSelecionados.contains(objetivo.id);
                      return _ObjetivoChip(
                        label: objetivo.label,
                        selecionado: selecionado,
                        onTap: () => _toggleObjetivo(objetivo.id),
                      );
                    }),

                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF2A2A2A), height: 1),
                    const SizedBox(height: 16),

                    // Opção "Sem metas no momento" — visualmente separada
                    _ObjetivoChip(
                      label: 'Sem metas no momento',
                      selecionado: _semMetasSelecionado,
                      onTap: _toggleSemMetas,
                      icone: Icons.block_flipped,
                      estiloAlternativo: true,
                    ),
                    const SizedBox(height: 8),
                    if (_semMetasSelecionado)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Sem problema! Você pode criar metas quando quiser, direto pelo app.',
                          style: TextStyle(
                            color: corTextoSecundario,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Botão continuar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _podeContinuar
                      ? () => widget.onContinuar(
                            _objetivosSelecionados.toList(),
                            _semMetasSelecionado,
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corRoxa,
                    disabledBackgroundColor: corCardInativo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Objetivo {
  final String id;
  final String label;
  _Objetivo(this.id, this.label);
}

class _ObjetivoChip extends StatelessWidget {
  final String label;
  final bool selecionado;
  final VoidCallback onTap;
  final IconData? icone;
  final bool estiloAlternativo;

  const _ObjetivoChip({
    required this.label,
    required this.selecionado,
    required this.onTap,
    this.icone,
    this.estiloAlternativo = false,
  });

  static const Color corRoxa = Color(0xFF8A2BE2);
  static const Color corCardInativo = Color(0xFF1A1A1A);
  static const Color corBordaInativa = Color(0xFF2A2A2A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selecionado
              ? corRoxa.withOpacity(estiloAlternativo ? 0.18 : 0.25)
              : corCardInativo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionado ? corRoxa : corBordaInativa,
            width: 1.5,
            style: estiloAlternativo ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            if (icone != null) ...[
              Icon(
                icone,
                size: 18,
                color: selecionado ? corRoxa : corTextoIconeInativo,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontStyle: estiloAlternativo
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
            if (selecionado)
              const Icon(Icons.check_circle, color: corRoxa, size: 20)
            else
              Icon(Icons.circle_outlined,
                  color: corTextoIconeInativo, size: 20),
          ],
        ),
      ),
    );
  }

  static const Color corTextoIconeInativo = Color(0xFF666666);
}