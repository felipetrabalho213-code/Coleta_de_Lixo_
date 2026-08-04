import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../controllers/notification_controller.dart';
import '../views/notification/notification_page.dart';

class FirebaseNotificationManager {
  static final FirebaseNotificationManager instance = FirebaseNotificationManager._internal();
  FirebaseNotificationManager._internal();

  // Chave de navegação global
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> inicializar() async {
    // 1. Permissão para receber notificações
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Inscrição no tópico
    await _messaging.subscribeToTopic('garanhuns_coleta');

    // 3. Recebe notificação com o APP ABERTO na tela (Primeiro plano)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationController.instance.adicionarNotificacaoFirebase(message);
    });

    // 4. Clique na notificação com o APP EM SEGUNDO PLANO
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotificationController.instance.adicionarNotificacaoFirebase(message);
      _abrirTelaHistorico();
    });

    // 5. Clique na notificação com o APP TOTALMENTE FECHADO
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        NotificationController.instance.adicionarNotificacaoFirebase(message);
        // Aguarda um pequeno delay para a interface carregar antes de navegar
        Future.delayed(const Duration(milliseconds: 500), () {
          _abrirTelaHistorico();
        });
      }
    });
  }

  // Função responsável por fazer a transição de tela
  void _abrirTelaHistorico() {
    final state = navigatorKey.currentState;
    if (state != null) {
      state.push(
        MaterialPageRoute(
          builder: (context) => const NotificationPage(),
        ),
      );
    }
  }
}