import 'package:flutter/material.dart';

class SpecialCollectionPage extends StatelessWidget {
  const SpecialCollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coleta Especial'),
      ),
      body: const Center(
        child: Text('Coleta Especial'),
      ),
    );
  }
}