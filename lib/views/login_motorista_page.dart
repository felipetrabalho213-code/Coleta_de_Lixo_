import 'package:flutter/material.dart';

// Caminhos corrigidos de acordo com a sua estrutura de pastas
import '../models/app_state.dart';
import 'driver/driver_page.dart';

class LoginMotoristaPage extends StatefulWidget {
  const LoginMotoristaPage({Key? key}) : super(key: key);

  @override
  State<LoginMotoristaPage> createState() => _LoginMotoristaPageState();
}

class _LoginMotoristaPageState extends State<LoginMotoristaPage> {
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  void _autenticarMotorista() {
    final cpfDigitado = _cpfController.text.replaceAll(RegExp(r'\D'), '');
    final senhaDigitada = _senhaController.text;

    if (cpfDigitado.isEmpty || senhaDigitada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe CPF e Senha!')),
      );
      return;
    }

    // Busca o motorista na lista global compartilhada
    try {
      final motorista = listaMotoristasGlobais.firstWhere((m) {
        final cpfCadastrado = m.cpf.replaceAll(RegExp(r'\D'), '');
        return cpfCadastrado == cpfDigitado && m.senha == senhaDigitada;
      });

      // Salva o motorista autenticado no AppState
      motoristaLogadoGlobal = motorista;

      // Redireciona para a Tela do Motorista
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DriverPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CPF ou Senha inválidos!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Motorista'),
        backgroundColor: const Color(0xFF1E9C49),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_shipping, size: 80, color: Color(0xFF1E9C49)),
            const SizedBox(height: 20),
            TextField(
              controller: _cpfController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'CPF',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E9C49),
                ),
                onPressed: _autenticarMotorista,
                child: const Text('ENTRAR', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}