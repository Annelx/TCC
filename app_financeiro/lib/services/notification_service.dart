import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'pending_transactions_service.dart';

const _roxo = Color.fromARGB(255, 138, 43, 226); // #8A2BE2

const _rotuloInput = 'Valor então categoria (ex: 50 Alimentação)';

/// Processa o texto digitado numa das ações (Saída/Entrada) e salva na
/// fila de pendentes, já marcando o tipo — usado tanto pelo handler de
/// primeiro plano quanto pelo de segundo plano (app fechado).
Future<void> _processarEntrada(NotificationResponse resposta) async {
  final ehSaida = resposta.actionId == NotificationService.acaoSaida;
  final ehEntrada = resposta.actionId == NotificationService.acaoEntrada;
  if (!ehSaida && !ehEntrada) return;
  if (resposta.input == null || resposta.input!.trim().isEmpty) return;

  final tipo = ehEntrada ? 'ENTRADA' : 'SAIDA';
  await PendingTransactionsService.adicionar('$tipo|${resposta.input!.trim()}');
  // Reposta a notificação — é isso que "confirma" pro Android que o app
  // terminou de processar, fechando o spinner de carregamento.
  await NotificationService.mostrarNotificacaoFixa();
}

/// Handler chamado quando o usuário responde à notificação com o APP
/// FECHADO (isolate separado — por isso precisa ser uma função de nível
/// top e marcada com @pragma, sem depender de nada da tela em memória).
@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse resposta) {
  _processarEntrada(resposta);
}

/// Serviço central de notificações do app. Cuida de:
/// - inicializar o plugin e pedir permissão ao usuário
/// - mostrar a notificação fixa (ongoing), com os botões "Saída"/"Entrada",
///   cada um com um campo de texto pra lançar a transação SEM abrir o app
///
/// Chame [inicializar] uma vez, cedo no ciclo de vida do app (no main.dart),
/// e [mostrarNotificacaoFixa] depois que o usuário estiver logado.
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _canalId = 'valora_atalhos';
  static const _canalNome = 'Atalhos rápidos';
  static const _canalDescricao = 'Notificação fixa com atalhos do Valora';
  static const _idNotificacaoFixa = 1;

  static const acaoSaida = 'nova_saida';
  static const acaoEntrada = 'nova_entrada';
  static const acaoNovaMeta = 'nova_meta';

  /// Callback pra ações que devem abrir o app (ex: "Nova meta"). Os atalhos
  /// de Saída/Entrada NÃO passam por aqui — são resolvidos silenciosamente,
  /// sem abrir nada, direto no toque.
  static void Function(String acao)? onAcaoTocada;

  static Future<void> inicializar() async {
    const configAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const configIOS = DarwinInitializationSettings();
    const config = InitializationSettings(android: configAndroid, iOS: configIOS);

    await _plugin.initialize(
      config,
      onDidReceiveNotificationResponse: (resposta) async {
        if (resposta.actionId == acaoSaida || resposta.actionId == acaoEntrada) {
          await _processarEntrada(resposta);
          return;
        }
        if (resposta.actionId != null) {
          onAcaoTocada?.call(resposta.actionId!);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
    );

    const canal = AndroidNotificationChannel(
      _canalId,
      _canalNome,
      description: _canalDescricao,
      importance: Importance.low, // sem som/vibração, é só um atalho
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(canal);
  }

  static Future<void> pedirPermissao() async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: false, sound: false);
  }

  /// Mostra (ou atualiza) a notificação fixa, com os botões "Saída" e
  /// "Entrada" — cada um abre um campo de texto pra lançar a transação
  /// sem abrir o app. O ícone que aparece aqui é o mesmo ícone do app
  /// (@mipmap/ic_launcher) — se ainda estiver mostrando o "F" do Flutter
  /// em vez da logo do Valora, o ícone do APP inteiro precisa ser trocado
  /// via flutter_launcher_icons (veja instruções à parte).
  static Future<void> mostrarNotificacaoFixa() async {
    final detalhesAndroid = AndroidNotificationDetails(
      _canalId,
      _canalNome,
      channelDescription: _canalDescricao,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      playSound: false,
      enableVibration: false,
      color: _roxo,
      colorized: true,
      icon: '@mipmap/ic_launcher',
      actions: [
        AndroidNotificationAction(
          acaoSaida,
          'Saída',
          inputs: const [AndroidNotificationActionInput(label: _rotuloInput)],
          contextual: false,
        ),
        AndroidNotificationAction(
          acaoEntrada,
          'Entrada',
          inputs: const [AndroidNotificationActionInput(label: _rotuloInput)],
          contextual: false,
        ),
      ],
    );
    final detalhes = NotificationDetails(android: detalhesAndroid);

    // Título diferente do nome do app, pra não duplicar "Valora" duas vezes
    // (o Android já mostra o nome do app sozinho, por cima do título).
    await _plugin.show(_idNotificacaoFixa, 'Lançar transação rápida', null, detalhes);
  }

  static Future<void> removerNotificacaoFixa() async {
    await _plugin.cancel(_idNotificacaoFixa);
  }
}