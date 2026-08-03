import 'package:firebase_messaging/firebase_messaging.dart';
import '../controllers/notification_controller.dart';

// Função de nível superior para tratar mensagens em segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  NotificationController.instance.adicionarNotificacaoFirebase(message);
}

class FirebaseNotificationManager {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> inicializar() async {
    // 1. Solicita permissão para exibir notificações no dispositivo
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Imprime o Token FCM no terminal para você usar no "Enviar mensagem de teste"
      try {
        String? token = await _firebaseMessaging.getToken();
        print("==================================================");
        print("MEU TOKEN FCM: $token");
        print("==================================================");
      } catch (e) {
        print("Erro ao obter o token FCM: $e");
      }

      // 3. Inscreve o dispositivo no tópico padrão da cidade
      await _firebaseMessaging.subscribeToTopic('garanhuns_coleta');

      // 4. Configura o manipulador de segundo plano
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 5. App ABERTO (Foreground)
      FirebaseMessaging.onMessage.listen((message) {
        NotificationController.instance.adicionarNotificacaoFirebase(message);
      });

      // 6. App em SEGUNDO PLANO (Ao clicar na notificação)
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        NotificationController.instance.adicionarNotificacaoFirebase(message);
      });
    }
  }
}