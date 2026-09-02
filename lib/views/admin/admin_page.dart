import 'package:flutter/material.dart';

// Modelos Globais de Dados
class Motorista {
  String nome;
  String cpf;
  String caminhao;
  String senha;

  Motorista({
    required this.nome,
    required this.cpf,
    required this.caminhao,
    this.senha = '123',
  });
}

class Rota {
  String id;
  String nome;
  String ruas;
  String horario;
  String cpfMotorista;

  Rota({
    required this.id,
    required this.nome,
    required this.ruas,
    required this.horario,
    required this.cpfMotorista,
  });
}

// Listas Simulares Globais
List<Motorista> listaMotoristasGlobais = [
  Motorista(nome: 'Carlos Silva', cpf: '123.456.789-00', caminhao: 'Caminhão #04', senha: '123'),
  Motorista(nome: 'João Santos', cpf: '987.654.321-11', caminhao: 'Caminhão #02', senha: '123'),
];

List<Rota> listaRotasGlobais = [
  Rota(
    id: '1',
    nome: 'Rota 02 - Bairro Central',
    ruas: 'Av. Brasil, Rua das Flores, Rua 15 de Novembro, Av. Pátio',
    horario: 'Segunda, Quarta e Sexta (07:00 às 13:00)',
    cpfMotorista: '123.456.789-00',
  ),
];

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Modal para Criar / Editar Motorista
  void _abrirModalMotorista({Motorista? motoristaExistente}) {
    final nomeCtrl = TextEditingController(text: motoristaExistente?.nome ?? '');
    final cpfCtrl = TextEditingController(text: motoristaExistente?.cpf ?? '');
    final caminhaoCtrl = TextEditingController(text: motoristaExistente?.caminhao ?? '');
    final senhaCtrl = TextEditingController(text: motoristaExistente?.senha ?? '123');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(motoristaExistente == null ? 'Cadastrar Novo Motorista' : 'Editar Motorista'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cpfCtrl,
                enabled: motoristaExistente == null, // Não permite alterar CPF de chave em edição
                decoration: const InputDecoration(labelText: 'Matrícula / CPF', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: caminhaoCtrl,
                decoration: const InputDecoration(labelText: 'Número do Caminhão', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: senhaCtrl,
                decoration: const InputDecoration(labelText: 'Senha de Acesso', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B4F)),
            onPressed: () {
              if (nomeCtrl.text.isNotEmpty && cpfCtrl.text.isNotEmpty) {
                setState(() {
                  if (motoristaExistente == null) {
                    listaMotoristasGlobais.add(
                      Motorista(
                        nome: nomeCtrl.text.trim(),
                        cpf: cpfCtrl.text.trim(),
                        caminhao: caminhaoCtrl.text.trim(),
                        senha: senhaCtrl.text.trim(),
                      ),
                    );
                  } else {
                    motoristaExistente.nome = nomeCtrl.text.trim();
                    motoristaExistente.caminhao = caminhaoCtrl.text.trim();
                    motoristaExistente.senha = senhaCtrl.text.trim();
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(motoristaExistente == null ? 'Motorista cadastrado!' : 'Motorista atualizado!'),
                    backgroundColor: const Color(0xFF006B4F),
                  ),
                );
              }
            },
            child: Text(motoristaExistente == null ? 'CADASTRAR' : 'SALVAR', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Modal para Criar / Editar Rota
  void _abrirModalRota({Rota? rotaExistente}) {
    final nomeCtrl = TextEditingController(text: rotaExistente?.nome ?? '');
    final ruasCtrl = TextEditingController(text: rotaExistente?.ruas ?? '');
    final horarioCtrl = TextEditingController(text: rotaExistente?.horario ?? '');
    String? cpfSelecionado = rotaExistente?.cpfMotorista ?? (listaMotoristasGlobais.isNotEmpty ? listaMotoristasGlobais.first.cpf : null);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text(rotaExistente == null ? 'Cadastrar Nova Rota' : 'Editar Rota'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: cpfSelecionado,
                    decoration: const InputDecoration(labelText: 'Motorista Responsável', border: OutlineInputBorder()),
                    items: listaMotoristasGlobais.map((mot) {
                      return DropdownMenuItem(
                        value: mot.cpf,
                        child: Text('${mot.nome} (${mot.cpf})'),
                      );
                    }).toList(),
                    onChanged: (val) => setModalState(() => cpfSelecionado = val),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nomeCtrl,
                    decoration: const InputDecoration(labelText: 'Nome da Rota', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: ruasCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Ruas / Itinerário', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: horarioCtrl,
                    decoration: const InputDecoration(labelText: 'Dias e Horários', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B4F)),
                onPressed: () {
                  if (nomeCtrl.text.isNotEmpty && cpfSelecionado != null) {
                    setState(() {
                      if (rotaExistente == null) {
                        listaRotasGlobais.add(Rota(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          nome: nomeCtrl.text.trim(),
                          ruas: ruasCtrl.text.trim(),
                          horario: horarioCtrl.text.trim(),
                          cpfMotorista: cpfSelecionado!,
                        ));
                      } else {
                        rotaExistente.nome = nomeCtrl.text.trim();
                        rotaExistente.ruas = ruasCtrl.text.trim();
                        rotaExistente.horario = horarioCtrl.text.trim();
                        rotaExistente.cpfMotorista = cpfSelecionado!;
                      }
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text(rotaExistente == null ? 'SALVAR' : 'ATUALIZAR', style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF006B4F),
        title: const Text('Painel ADM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.map), text: 'Monitorar'),
            Tab(icon: Icon(Icons.person), text: 'Motoristas'),
            Tab(icon: Icon(Icons.alt_route), text: 'Rotas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMapaMonitoramento(),
          _buildAbaMotoristas(),
          _buildAbaRotas(),
        ],
      ),
    );
  }

  Widget _buildMapaMonitoramento() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text('Acompanhamento da Frota em Tempo Real', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Aba 2: Motoristas (Cadastrar, Listar, Editar e Excluir)
  Widget _buildAbaMotoristas() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B4F),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _abrirModalMotorista(),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('CADASTRAR NOVO MOTORISTA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          const Text('Motoristas Cadastrados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: listaMotoristasGlobais.isEmpty
                ? const Center(child: Text('Nenhum motorista cadastrado.'))
                : ListView.builder(
                    itemCount: listaMotoristasGlobais.length,
                    itemBuilder: (context, index) {
                      final motorista = listaMotoristasGlobais[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF006B4F),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(motorista.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('CPF: ${motorista.cpf}\n${motorista.caminhao}'),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF006B4F)),
                                onPressed: () => _abrirModalMotorista(motoristaExistente: motorista),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    listaMotoristasGlobais.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Aba 3: Rotas (Cadastrar, Listar, Editar e Excluir)
  Widget _buildAbaRotas() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B4F),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _abrirModalRota(),
            icon: const Icon(Icons.add_road, color: Colors.white),
            label: const Text('CADASTRAR NOVA ROTA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          const Text('Rotas Existentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: listaRotasGlobais.isEmpty
                ? const Center(child: Text('Nenhuma rota cadastrada.'))
                : ListView.builder(
                    itemCount: listaRotasGlobais.length,
                    itemBuilder: (context, index) {
                      final rota = listaRotasGlobais[index];
                      final motoristaRespon = listaMotoristasGlobais.firstWhere(
                        (m) => m.cpf == rota.cpfMotorista,
                        orElse: () => Motorista(nome: 'Sem Atribuição', cpf: '', caminhao: ''),
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(rota.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Color(0xFF006B4F)),
                                        onPressed: () => _abrirModalRota(rotaExistente: rota),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            listaRotasGlobais.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Motorista: ${motoristaRespon.nome} (${rota.cpfMotorista})',
                                style: const TextStyle(color: Color(0xFF006B4F), fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text('Ruas: ${rota.ruas}', style: TextStyle(color: Colors.grey[700])),
                              const SizedBox(height: 4),
                              Text(rota.horario, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}