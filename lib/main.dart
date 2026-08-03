import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase_notification_manager.dart';
import 'views/home/home_page.dart';

void main() async {
  // Necessário para executar código assíncrono antes do runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as opções da plataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ativa a escuta e permissão de notificações do Firebase Cloud Messaging
  final firebaseManager = FirebaseNotificationManager();
  await firebaseManager.inicializar();

  runApp(const SegueColetaApp());
}

class SegueColetaApp extends StatelessWidget {
  const SegueColetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Segue Coleta',
      home: const HomePage(),
      
      // Suporte ao calendário e componentes nativos em PT-BR
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
    );
  }
}