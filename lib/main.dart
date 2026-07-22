import 'package:flutter/material.dart';
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
    );
  }
}