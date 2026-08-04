import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'services/firebase_notification_manager.dart';
import 'views/home/home_page.dart';

void main() async {
  // Garantir a inicialização dos bindings nativos do Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a formatação de datas do intl para Português (Brasil)
  await initializeDateFormatting('pt_BR', null);

  // Inicializa o Firebase com as configurações da plataforma atual
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa o gerenciador de notificações do Firebase
  await FirebaseNotificationManager.instance.inicializar();

  runApp(const SegueColetaApp());
}

class SegueColetaApp extends StatelessWidget {
  const SegueColetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Segue Coleta',

      // 📍 Chave global de navegação para abrir a tela de Notificações ao clicar nos avisos
      navigatorKey: FirebaseNotificationManager.navigatorKey,

      // Tela inicial do aplicativo
      home: const HomePage(),

      // Suporte ao calendário e componentes em Português (Brasil)
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