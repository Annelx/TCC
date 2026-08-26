import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';
import 'screens/splash_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/add_meta_screen.dart';
import 'services/notification_service.dart';

/// Chave global de navegação — permite navegar de qualquer lugar do app
/// (inclusive de fora da árvore de widgets, como nos callbacks do
/// quick_actions e das notificações) sem precisar de um BuildContext local.
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.inicializar();
  NotificationService.onAcaoTocada = (acao) {
    if (acao == NotificationService.acaoNovaMeta) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const AddMetaScreen()),
      );
    }
  };
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static const roxo = Color(0xFF8A2BE2); // BlueViolet

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final QuickActions _quickActions = const QuickActions();

  @override
  void initState() {
    super.initState();
    _configurarAtalhos();
  }

  void _configurarAtalhos() {
    _quickActions.initialize((tipo) {
      // Disparado quando o usuário toca no atalho (segurando o ícone do
      // app na tela inicial do celular). Empurra a tela direto por cima
      // de onde o app estiver — se o usuário ainda não tiver feito login,
      // a tela abre em cima da Splash/Login mesmo assim.
      switch (tipo) {
        case 'nova_transacao':
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
          break;
        case 'nova_meta':
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const AddMetaScreen()),
          );
          break;
      }
    });

    _quickActions.setShortcutItems(const [
      ShortcutItem(
        type: 'nova_transacao',
        localizedTitle: 'Nova transação',
        icon: 'ic_shortcut_transacao', // ver nota no README sobre o ícone
      ),
      ShortcutItem(
        type: 'nova_meta',
        localizedTitle: 'Nova meta',
        icon: 'ic_shortcut_meta',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'App Financeiro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: MyApp.roxo,
          brightness: Brightness.dark,
          primary: MyApp.roxo,
          onPrimary: Colors.white,
          surface: const Color(0xFF121212),
          onSurface: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MyApp.roxo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: MyApp.roxo),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: MyApp.roxo,
          ),
        ),
        iconTheme: const IconThemeData(color: MyApp.roxo),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.white54),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIconColor: MyApp.roxo,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: MyApp.roxo, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        dividerTheme: const DividerThemeData(color: Colors.white24),
      ),
      home: const SplashScreen(),
    );
  }
}