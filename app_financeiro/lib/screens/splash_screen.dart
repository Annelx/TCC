import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _mostrarLogoCompleta = true;

  late final AnimationController _giroController;
  late final Animation<double> _giro;

  @override
  void initState() {
    super.initState();

    _giroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _giro = Tween<double>(begin: 0, end: -1).animate(
      CurvedAnimation(parent: _giroController, curve: Curves.easeOut),
    );

    _iniciarSequencia();
  }

  void _iniciarSequencia() async {
    // 1. Mostra a logo completa (símbolo + "VALORA")
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    // 2. Troca para só o símbolo
    setState(() {
      _mostrarLogoCompleta = false;
    });

    // 3. Espera a troca (fade) terminar antes de girar
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // 4. A logo gira até o fim, sem interrupção
    await _giroController.forward();
    if (!mounted) return;

    // 5. Navega para o Login com fade leve
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _giroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: _mostrarLogoCompleta
              ? Image.asset(
                  'assets/images/valora_logo_completa.png',
                  key: const ValueKey('logo_completa'),
                  width: 260,
                )
              : RotationTransition(
                  turns: _giro,
                  key: const ValueKey('logo_simbolo'),
                  child: Image.asset(
                    'assets/images/valora_logo.png',
                    width: 64,
                  ),
                ),
        ),
      ),
    );
  }
}