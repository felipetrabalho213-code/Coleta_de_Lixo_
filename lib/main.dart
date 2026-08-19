// PR 1 — CLEAN CODE


// Imports organizados: de fora para dentro
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'services/firebase_notification_manager.dart';
import 'views/home/home_page.dart';

//Valores fixos em um lugar só
class AppConfig {
static const String appTitle = 'Segue Coleta';
static const String locale = 'pt_BR';
}

//Ponto de entrada
void main() async {
WidgetsFlutterBinding.ensureInitialized();

//Cada coisa em sua função
await _initializeDateFormatting();
await _initializeFirebase();
await _initializeNotificationManager();

runApp(const SegueColetaApp());
}

//Nome claro: formata datas
Future<void> _initializeDateFormatting() async {
await initializeDateFormatting(AppConfig.locale, null);
}

//Nome claro: inicia Firebase
Future<void> _initializeFirebase() async {
await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);
}

//Nome claro: inicia notificações
Future<void> _initializeNotificationManager() async {
await FirebaseNotificationManager.instance.inicializar();
}

class SegueColetaApp extends StatelessWidget {
const SegueColetaApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: AppConfig.appTitle,
navigatorKey: FirebaseNotificationManager.navigatorKey,
home: const HomePage(),

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