// ==========================================
// PR 2 — PRINCÍPIOS SOLID
// ==========================================

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'services/firebase_notification_manager.dart';
import 'views/home/home_page.dart';

//Contrato — o que a configuração TEM que ter
abstract class IAppConfig {
String get appTitle;
String get defaultLocale;
String get languageCode;

String get countryCode;
}

//Contrato pequeno — só o que precisa
abstract class IInitializable {
Future<void> initialize();
}

// Implementação do contrato de configuração
class AppConfig implements IAppConfig {
@override
final String appTitle = 'Segue Coleta';
@override
final String defaultLocale = 'pt_BR';
@override
final String languageCode = 'pt';
@override
final String countryCode = 'BR';
}

//Só cuida de datas
class DateFormatService implements IInitializable {
final IAppConfig config;
DateFormatService(this.config);

@override
Future<void> initialize() async {
await initializeDateFormatting(config.defaultLocale, null);

}
}

//Só cuida do Firebase
class FirebaseService implements IInitializable {
@override
Future<void> initialize() async {
await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);
}
}

//Só cuida de notificações
class NotificationService implements IInitializable {
@override
Future<void> initialize() async {
await FirebaseNotificationManager.instance.inicializar();
}
}

void main() async {
WidgetsFlutterBinding.ensureInitialized();

final IAppConfig config = AppConfig();

//Adiciona serviço novo aqui, sem mudar o resto!
final List<IInitializable> servicos = [

DateFormatService(config),
FirebaseService(),
NotificationService(),
];

for (final servico in servicos) {
await servico.initialize();
}

runApp(const SegueColetaApp());
}

class SegueColetaApp extends StatelessWidget {
const SegueColetaApp({super.key});

@override
Widget build(BuildContext context) {
final IAppConfig config = AppConfig();

return MaterialApp(
debugShowCheckedModeBanner: false,
title: config.appTitle,
navigatorKey: FirebaseNotificationManager.navigatorKey,
home: const HomePage(),
localizationsDelegates: const [
GlobalMaterialLocalizations.delegate,
GlobalWidgetsLocalizations.delegate,
GlobalCupertinoLocalizations.delegate,

],
supportedLocales: [
Locale(config.languageCode, config.countryCode),
],
);
}
}