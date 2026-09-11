import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/app_state.dart';
import '../admin/admin_page.dart';
import '../calendar/calendar_page.dart';
import '../driver/driver_page.dart';
import '../notification/notification_page.dart';
import '../special_collection/special_collection_page.dart';
import '../truck/truck_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Modal de Cadastro e Login do Cidadão
  void _exibirModalCidadao(BuildContext context) {
    final nomeCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final cepCtrl = TextEditingController();
    final logradouroCtrl = TextEditingController();
    final numeroCtrl = TextEditingController();
    final bairroCtrl = TextEditingController();
    final cidadeUfCtrl = TextEditingController();
    final telefoneCtrl = TextEditingController();
    final senhaCtrl = TextEditingController();

    bool carregandoCep = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Função interna para buscar CEP via ViaCEP API
          Future<void> buscarCep(String cep) async {
            final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
            if (cepLimpo.length != 8) return;

            setModalState(() => carregandoCep = true);

            try {
              final response = await http.get(
                Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/'),
              );

              if (response.statusCode == 200) {
                final data = jsonDecode(response.body);
                if (data['erro'] == true) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('CEP não encontrado!')),
                    );
                  }
                } else {
                  setModalState(() {
                    logradouroCtrl.text = data['logradouro'] ?? '';
                    bairroCtrl.text = data['bairro'] ?? '';
                    cidadeUfCtrl.text = '${data['localidade']} - ${data['uf']}';
                  });
                }
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro ao buscar o CEP.')),
                );
              }
            } finally {
              setModalState(() => carregandoCep = false);
            }
          }

          return DefaultTabController(
            length: 2,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.85,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Área do Cidadão',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const TabBar(
                        labelColor: Color(0xFF006B4F),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Color(0xFF006B4F),
                        tabs: [
                          Tab(text: 'Cadastrar'),
                          Tab(text: 'Entrar'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 380, // Aumentado levemente para acomodar melhor os novos campos
                        child: TabBarView(
                          children: [
                            // Aba Cadastrar
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: nomeCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Nome Completo',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: 'E-mail',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Campo CEP com busca automática
                                  TextField(
                                    controller: cepCtrl,
                                    keyboardType: TextInputType.number,
                                    maxLength: 9,
                                    decoration: InputDecoration(
                                      labelText: 'CEP (ex: 00000-000)',
                                      counterText: '',
                                      border: const OutlineInputBorder(),
                                      isDense: true,
                                      suffixIcon: carregandoCep
                                          ? const Padding(
                                              padding: EdgeInsets.all(10.0),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFF006B4F),
                                              ),
                                            )
                                          : IconButton(
                                              icon: const Icon(
                                                Icons.search,
                                                color: Color(0xFF006B4F),
                                              ),
                                              onPressed: () =>
                                                  buscarCep(cepCtrl.text),
                                            ),
                                    ),
                                    onChanged: (val) {
                                      final valLimpo = val.replaceAll(
                                        RegExp(r'[^0-9]'),
                                        '',
                                      );
                                      if (valLimpo.length == 8) {
                                        buscarCep(valLimpo);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 10),

                                  // Logradouro e Número
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextField(
                                          controller: logradouroCtrl,
                                          decoration: const InputDecoration(
                                            labelText: 'Rua/Avenida',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 1,
                                        child: TextField(
                                          controller: numeroCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Nº',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Bairro e Cidade/UF
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: bairroCtrl,
                                          decoration: const InputDecoration(
                                            labelText: 'Bairro',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: cidadeUfCtrl,
                                          readOnly: true,
                                          decoration: const InputDecoration(
                                            labelText: 'Cidade/UF',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  TextField(
                                    controller: telefoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      labelText: 'Telefone',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF006B4F),
                                      minimumSize: const Size.fromHeight(45),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (nomeCtrl.text.isNotEmpty &&
                                          emailCtrl.text.isNotEmpty &&
                                          logradouroCtrl.text.isNotEmpty) {
                                        final enderecoFormatado =
                                            '${logradouroCtrl.text.trim()}, ${numeroCtrl.text.trim()} - ${bairroCtrl.text.trim()}';

                                        setState(() {
                                          usuarioLogadoGlobal = UsuarioCidadao(
                                            nome: nomeCtrl.text.trim(),
                                            email: emailCtrl.text.trim(),
                                            endereco: enderecoFormatado,
                                            telefone: telefoneCtrl.text.trim(),
                                          );
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Cadastro realizado com sucesso!',
                                            ),
                                            backgroundColor: Color(0xFF006B4F),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'SALVAR CADASTRO',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Aba Entrar
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: emailCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'E-mail',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: senhaCtrl,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Senha',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF006B4F),
                                      minimumSize: const Size.fromHeight(45),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (emailCtrl.text.isNotEmpty) {
                                        setState(() {
                                          usuarioLogadoGlobal = UsuarioCidadao(
                                            nome: 'Usuário',
                                            email: emailCtrl.text.trim(),
                                            endereco: 'Rua São José',
                                            telefone: '(00) 00000-0000',
                                          );
                                        });
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text(
                                      'ENTRAR',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Modal de Acesso Restrito (ADM / Motorista)
  void _exibirModalLogin(BuildContext context) {
    final cpfController = TextEditingController();
    final senhaController = TextEditingController();
    int perfilSelecionado = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Motorista')),
                            selected: perfilSelecionado == 0,
                            selectedColor: const Color(0xFF006B4F),
                            labelStyle: TextStyle(
                              color: perfilSelecionado == 0
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() => perfilSelecionado = 0);
                              }
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
                              color: perfilSelecionado == 1
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() => perfilSelecionado = 1);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: cpfController,
                      decoration: InputDecoration(
                        labelText: perfilSelecionado == 0
                            ? 'CPF do Motorista'
                            : 'E-mail do ADM',
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006B4F),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (perfilSelecionado == 0) {
                          final cpfDigitado = cpfController.text.trim();
                          final senhaDigitada = senhaController.text.trim();

                          final motoristaLogado =
                              listaMotoristasGlobais.firstWhere(
                            (m) =>
                                m.cpf == cpfDigitado &&
                                m.senha == senhaDigitada,
                            orElse: () => Motorista(
                              nome: '',
                              cpf: '',
                              caminhao: '',
                              senha: '',
                            ),
                          );

                          if (motoristaLogado.cpf.isNotEmpty) {
                            motoristaLogadoGlobal = motoristaLogado;
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DriverPage(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('CPF ou Senha incorretos!'),
                              ),
                            );
                          }
                        } else {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminPage(),
                            ),
                          );
                        }
                      },
                      child: Text(
                        perfilSelecionado == 0
                            ? 'ENTRAR COMO MOTORISTA'
                            : 'ENTRAR COMO ADM',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Topo com Logo e Ícone de Login Restrito
              Row(
                children: [
                  const SizedBox(width: 48),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/teste.png',
                        height: 80,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.eco,
                          size: 60,
                          color: Color(0xFF006B4F),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.account_circle_outlined,
                      color: Color(0xFF006B4F),
                      size: 32,
                    ),
                    tooltip: 'Acesso Restrito',
                    onPressed: () => _exibirModalLogin(context),
                  ),
                ],
              ),

              // SAUDAÇÃO LOGO ABAIXO DA LOGO
              if (usuarioLogadoGlobal != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Olá, ${usuarioLogadoGlobal!.nome}!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006B4F),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Grade de Botões de Recursos
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

                    const SizedBox(height: 24),

                    // BOTÃO SUMIRÁ QUANDO O USUÁRIO LOGAR
                    if (usuarioLogadoGlobal == null)
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006B4F),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 4,
                          ),
                          onPressed: () => _exibirModalCidadao(context),
                          icon: const Icon(Icons.login, color: Colors.white),
                          label: const Text(
                            'ENTRAR / CADASTRAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
            ).then((_) => setState(() {}));
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