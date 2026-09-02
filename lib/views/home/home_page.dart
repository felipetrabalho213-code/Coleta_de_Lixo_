import 'package:flutter/material.dart';

import '../../controllers/home_controller.dart';
import '../admin/admin_page.dart';
import '../calendar/calendar_page.dart';
import '../driver/driver_page.dart';
import '../notification/notification_page.dart';
import '../special_collection/special_collection_page.dart';
import '../truck/truck_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Modal de Login para Motorista e ADM
  void _exibirModalLogin(BuildContext context) {
    final cpfController = TextEditingController();
    final senhaController = TextEditingController();
    int perfilSelecionado = 0; // 0 = Motorista, 1 = ADM

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.85,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Acesso Restrito',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Seleção do Perfil (Motorista ou ADM)
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Motorista')),
                            selected: perfilSelecionado == 0,
                            selectedColor: const Color(0xFF006B4F),
                            labelStyle: TextStyle(
                              color: perfilSelecionado == 0 ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) setModalState(() => perfilSelecionado = 0);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('ADM')),
                            selected: perfilSelecionado == 1,
                            selectedColor: const Color(0xFF006B4F),
                            labelStyle: TextStyle(
                              color: perfilSelecionado == 1 ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) setModalState(() => perfilSelecionado = 1);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Campos do Formulário
                    TextField(
                      controller: cpfController,
                      decoration: InputDecoration(
                        labelText: perfilSelecionado == 0 ? 'CPF do Motorista' : 'E-mail do ADM',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: senhaController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Botão Entrar com Validação
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006B4F),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (perfilSelecionado == 0) {
                          final cpfDigitado = cpfController.text.trim();
                          final senhaDigitada = senhaController.text.trim();

                          // Procura o motorista específico na lista cadastrada
                          final motoristaLogado = listaMotoristasGlobais.firstWhere(
                            (m) => m.cpf == cpfDigitado && m.senha == senhaDigitada,
                            orElse: () => Motorista(nome: '', cpf: '', caminhao: ''),
                          );

                          if (motoristaLogado.cpf.isNotEmpty) {
                            Navigator.pop(context); // Fecha o modal
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DriverPage(motorista: motoristaLogado),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('CPF não cadastrado ou senha incorreta!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          // Acesso Painel ADM
                          Navigator.pop(context); // Fecha o modal
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminPage()),
                          );
                        }
                      },
                      child: Text(
                        perfilSelecionado == 0 ? 'ENTRAR COMO MOTORISTA' : 'ENTRAR COMO ADM',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = HomeController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Cabeçalho com ícone de login
              Row(
                children: [
                  const SizedBox(width: 48),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/teste.png',
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_circle_outlined, color: Color(0xFF006B4F), size: 32),
                    tooltip: 'Login Motorista / ADM',
                    onPressed: () => _exibirModalLogin(context),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        buildCard(
                          context: context,
                          icon: Icons.arrow_downward,
                          title: 'Ver\nCaminhão',
                          color: const Color(0xFF006B4F),
                          page: const TruckPage(),
                        ),
                        buildCard(
                          context: context,
                          icon: Icons.notifications_none,
                          title: 'Receber\nAviso',
                          color: const Color(0xFF006B4F),
                          page: const NotificationPage(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        buildCard(
                          context: context,
                          icon: Icons.calendar_today,
                          title: 'Calendário',
                          color: const Color(0xFF006B4F),
                          page: const CalendarPage(),
                        ),
                        buildCard(
                          context: context,
                          icon: Icons.menu_book,
                          title: 'Coleta\nEspecial',
                          color: const Color(0xFF006B4F),
                          page: const SpecialCollectionPage(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required Widget page,
  }) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(icon, color: color, size: 26),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}