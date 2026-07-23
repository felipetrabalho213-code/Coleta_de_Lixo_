import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ Importe isso
import 'views/home/home_page.dart';

void main() {
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
      // ✅ Adicione essas linhas para o calendário em PT funcionar
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