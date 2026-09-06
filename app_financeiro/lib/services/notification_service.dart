import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const _roxo = Color.fromARGB(255, 138, 43, 226); // #8A2BE2

/// Serviço central de notificações do app. Mostra uma notificação fixa
/// (ongoing) com um botão "Nova transação" — ao tocar, o app abre direto
/// na tela de nova transação (comportamento simples e comprovadamente
/// confiável nesse ambiente — testamos e confirmamos que toques comuns
/// na notificação chegam certinho no app; já a digitação direto dentro
/// da notificação, via campo de texto, não funcionou de forma confiável).
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _canalId = 'valora_atalhos';
  static const _canalNome = 'Atalhos rápidos';
  static const _canalDescricao = 'Notificação fixa com atalhos do Valora';
  static const _idNotificacaoFixa = 1;

  static const acaoNovaTransacao = 'nova_transacao';
  static const acaoNovaMeta = 'nova_meta';

  /// Callback chamado quando o usuário toca em algum botão da notificação
  /// — configurado no main.dart pra decidir pra onde navegar.
  static void Function(String acao)? onAcaoTocada;

  static Future<void> inicializar() async {
    const configAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const configIOS = DarwinInitializationSettings();
    const config = InitializationSettings(android: configAndroid, iOS: configIOS);

    await _plugin.initialize(
      config,
      onDidReceiveNotificationResponse: (resposta) {
        if (resposta.actionId != null) {
          onAcaoTocada?.call(resposta.actionId!);
        }
      },
    );

    const canal = AndroidNotificationChannel(
      _canalId,
      _canalNome,
      description: _canalDescricao,
      importance: Importance.low,
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

  static Future<void> mostrarNotificacaoFixa() async {
    const detalhesAndroid = AndroidNotificationDetails(
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
          acaoNovaTransacao,
          'Nova transação',
          showsUserInterface: true,
        ),
      ],
    );
    const detalhes = NotificationDetails(android: detalhesAndroid);

    await _plugin.show(_idNotificacaoFixa, 'Lançar transação rápida', null, detalhes);
  }

  static Future<void> removerNotificacaoFixa() async {
    await _plugin.cancel(_idNotificacaoFixa);
  }
}