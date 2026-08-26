import 'package:flutter/material.dart';

/// Molde reutilizável pra todas as telas do onboarding: cabeçalho com botão
/// de voltar (opcional), barra de progresso, ícone circular, título e
/// subtítulo — seguido do conteúdo específico de cada passo (o [child]) e,
/// por fim, o botão de ação no rodapé (o [footer]).
///
/// Uso dentro de um _step.dart:
///
/// OnboardingStepScaffold(
///   icone: Icons.person_outline,
///   titulo: 'Vamos começar com seu perfil',
///   subtitulo: 'Essas informações são básicas...',
///   passoAtual: 1,
///   totalPassos: 7,
///   onVoltar: () => Navigator.of(context).maybePop(), // null esconde o botão
///   footer: ElevatedButton(onPressed: _continuar, child: Text('Continuar')),
///   child: Column(children: [ ...campos do formulário... ]),
/// )
class OnboardingStepScaffold extends StatelessWidget {
  static const roxo = Color(0xFF8A2BE2);

  final IconData icone;
  final String titulo;
  final String subtitulo;
  final int passoAtual;
  final int totalPassos;
  final VoidCallback? onVoltar;
  final Widget child;
  final Widget footer;

  const OnboardingStepScaffold({
    super.key,
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.passoAtual,
    required this.totalPassos,
    required this.child,
    required this.footer,
    this.onVoltar,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // Linha superior: voltar + barra de progresso + contador
            Row(
              children: [
                SizedBox(
                  width: 40,
                  child: onVoltar != null
                      ? IconButton(
                          onPressed: onVoltar,
                          icon: const Icon(Icons.arrow_back),
                          padding: EdgeInsets.zero,
                        )
                      : null,
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: passoAtual / totalPassos,
                      minHeight: 6,
                      backgroundColor: const Color(0xFF2A2A2A),
                      valueColor: const AlwaysStoppedAnimation(roxo),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$passoAtual de $totalPassos',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),

            const SizedBox(height: 24),

            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: roxo.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, color: roxo, size: 32),
              ),
            ),
            const SizedBox(height: 24),

            Text(titulo, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(subtitulo, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 32),

            Expanded(child: SingleChildScrollView(child: child)),

            const SizedBox(height: 16),
            footer,
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}