import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/app_state.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _opcaoSelecionada = 0;

  // Controllers para Cadastro de Rota
  final TextEditingController _nomeRotaController = TextEditingController();
  final TextEditingController _ruasController = TextEditingController();
  DateTime? _dataHoraSelecionada;
  Motorista? _motoristaSelecionadoParaRota;

  // Controllers para Cadastro de Motorista
  final TextEditingController _nomeMotoristaController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _caminhaoController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  // Coordenadas Centrais de Garanhuns - PE
  final LatLng _coordenadaGaranhuns = const LatLng(-8.8828, -36.4967);

  // Pontos de apoio estratégicos em Garanhuns para plotar os caminhões no mapa
  final List<LatLng> _pontosGaranhuns = const [
    LatLng(-8.8828, -36.4967), // Centro / Av. Santo Antônio
    LatLng(-8.8890, -36.4850), // Heliópolis / Av. Rui Barbosa
    LatLng(-8.8750, -36.4910), // Severiano Moraes Filho
    LatLng(-8.8920, -36.5020), // Boa Vista
    LatLng(-8.8780, -36.5080), // Magano
    LatLng(-8.8980, -36.4780), // São José
  ];

  @override
  void dispose() {
    _nomeRotaController.dispose();
    _ruasController.dispose();
    _nomeMotoristaController.dispose();
    _cpfController.dispose();
    _caminhaoController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // Selecionar Data e Hora para Rota
  Future<DateTime?> _selecionarDataHora(BuildContext context, [DateTime? inicial]) async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: inicial ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2030),
    );

    if (data != null) {
      final TimeOfDay? hora = await showTimePicker(
        context: context,
        initialTime: inicial != null ? TimeOfDay.fromDateTime(inicial) : TimeOfDay.now(),
      );

      if (hora != null) {
        return DateTime(
          data.year,
          data.month,
          data.day,
          hora.hour,
          hora.minute,
        );
      }
    }
    return inicial;
  }

  // Cadastrar Rota
  void _cadastrarRota() {
    if (_nomeRotaController.text.isEmpty || _ruasController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o nome e as ruas da rota!')),
      );
      return;
    }

    if (_motoristaSelecionadoParaRota == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o motorista para esta rota!')),
      );
      return;
    }

    final dataFormatada = _dataHoraSelecionada != null
        ? '${_dataHoraSelecionada!.day}/${_dataHoraSelecionada!.month} às ${_dataHoraSelecionada!.hour}:${_dataHoraSelecionada!.minute.toString().padLeft(2, '0')}'
        : 'Horário não informado';

    setState(() {
      listaRotasGlobais.add(
        Rota(
          id: 'rota_${DateTime.now().millisecondsSinceEpoch}',
          nome: _nomeRotaController.text,
          ruas: _ruasController.text,
          horario: dataFormatada,
          dataExata: _dataHoraSelecionada,
          motoristaNome: _motoristaSelecionadoParaRota!.nome,
          motoristaCpf: _motoristaSelecionadoParaRota!.cpf,
        ),
      );

      _nomeRotaController.clear();
      _ruasController.clear();
      _dataHoraSelecionada = null;
      _motoristaSelecionadoParaRota = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rota cadastrada e atribuída ao motorista!')),
    );
  }

  // MODAL PARA EDITAR ROTA (Mudar motorista, ruas, horários)
  void _abrirModalEditarRota(Rota rotaOriginal, int index) {
    final editNomeCtrl = TextEditingController(text: rotaOriginal.nome);
    final editRuasCtrl = TextEditingController(text: rotaOriginal.ruas);
    DateTime? editDataHora = rotaOriginal.dataExata;
    
    // Procura motorista atual da rota na lista global
    Motorista? editMotorista = listaMotoristasGlobais.firstWhere(
      (m) => m.cpf == rotaOriginal.motoristaCpf,
      orElse: () => listaMotoristasGlobais.isNotEmpty ? listaMotoristasGlobais.first : Motorista(nome: '', cpf: '', caminhao: '', senha: ''),
    );
    if (editMotorista.cpf.isEmpty) editMotorista = null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Editar Rota', style: TextStyle(color: Color(0xFF1E9C49), fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: editNomeCtrl,
                      decoration: const InputDecoration(labelText: 'Nome da Rota', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: editRuasCtrl,
                      decoration: const InputDecoration(labelText: 'Ruas Atendidas', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Motorista>(
                      value: editMotorista,
                      decoration: const InputDecoration(
                        labelText: 'Reatribuir Motorista',
                        border: OutlineInputBorder(),
                      ),
                      items: listaMotoristasGlobais.map((m) {
                        return DropdownMenuItem<Motorista>(
                          value: m,
                          child: Text('${m.nome} (${m.caminhao})'),
                        );
                      }).toList(),
                      onChanged: (novo) {
                        setModalState(() => editMotorista = novo);
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final novaData = await _selecionarDataHora(context, editDataHora);
                        if (novaData != null) {
                          setModalState(() => editDataHora = novaData);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Color(0xFF1E9C49)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                editDataHora == null
                                    ? 'Selecionar Data/Hora'
                                    : '${editDataHora!.day}/${editDataHora!.month} às ${editDataHora!.hour}:${editDataHora!.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E9C49)),
                  onPressed: () {
                    if (editNomeCtrl.text.isEmpty || editRuasCtrl.text.isEmpty) return;

                    final dataFormatada = editDataHora != null
                        ? '${editDataHora!.day}/${editDataHora!.month} às ${editDataHora!.hour}:${editDataHora!.minute.toString().padLeft(2, '0')}'
                        : rotaOriginal.horario;

                    setState(() {
                      listaRotasGlobais[index] = Rota(
                        id: rotaOriginal.id,
                        nome: editNomeCtrl.text,
                        ruas: editRuasCtrl.text,
                        horario: dataFormatada,
                        dataExata: editDataHora,
                        motoristaNome: editMotorista?.nome ?? rotaOriginal.motoristaNome,
                        motoristaCpf: editMotorista?.cpf ?? rotaOriginal.motoristaCpf,
                      );
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rota atualizada com sucesso!')),
                    );
                  },
                  child: const Text('SALVAR', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Cadastrar Motorista
  void _cadastrarMotorista() {
    if (_nomeMotoristaController.text.isEmpty ||
        _cpfController.text.isEmpty ||
        _caminhaoController.text.isEmpty ||
        _senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos do motorista!')),
      );
      return;
    }

    final cpfLimpo = _cpfController.text.replaceAll(RegExp(r'\D'), '');

    setState(() {
      listaMotoristasGlobais.add(
        Motorista(
          nome: _nomeMotoristaController.text,
          cpf: cpfLimpo,
          caminhao: _caminhaoController.text,
          senha: _senhaController.text,
        ),
      );

      _nomeMotoristaController.clear();
      _cpfController.clear();
      _caminhaoController.clear();
      _senhaController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Motorista cadastrado no sistema!')),
    );
  }

  // MODAL PARA EDITAR MOTORISTA
  void _abrirModalEditarMotorista(Motorista m, int index) {
    final editNome = TextEditingController(text: m.nome);
    final editCpf = TextEditingController(text: m.cpf);
    final editCaminhao = TextEditingController(text: m.caminhao);
    final editSenha = TextEditingController(text: m.senha);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Editar Motorista', style: TextStyle(color: Color(0xFF1E9C49), fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: editNome, decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: editCpf, decoration: const InputDecoration(labelText: 'CPF', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: editCaminhao, decoration: const InputDecoration(labelText: 'Caminhão', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: editSenha, decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E9C49)),
            onPressed: () {
              setState(() {
                listaMotoristasGlobais[index] = Motorista(
                  nome: editNome.text,
                  cpf: editCpf.text.replaceAll(RegExp(r'\D'), ''),
                  caminhao: editCaminhao.text,
                  senha: editSenha.text,
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Motorista atualizado com sucesso!')),
              );
            },
            child: const Text('SALVAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E9C49),
        title: const Text('Painel Administrativo'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1E9C49),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBotaoAba(0, 'Rotas', Icons.alt_route),
                _buildBotaoAba(1, 'Motoristas', Icons.person_add),
                _buildBotaoAba(2, 'Acompanhamento', Icons.map),
              ],
            ),
          ),
          Expanded(
            child: _opcaoSelecionada == 0
                ? _buildTelaRotas()
                : _opcaoSelecionada == 1
                    ? _buildTelaMotoristas()
                    : _buildTelaAcompanhamento(),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoAba(int index, String titulo, IconData icone) {
    bool selecionado = _opcaoSelecionada == index;
    return GestureDetector(
      onTap: () => setState(() => _opcaoSelecionada = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selecionado ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icone, color: selecionado ? const Color(0xFF1E9C49) : Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              titulo,
              style: TextStyle(
                color: selecionado ? const Color(0xFF1E9C49) : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ABA 1: CADASTRO E EDIÇÃO DE ROTAS
  Widget _buildTelaRotas() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cadastrar Nova Rota',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E9C49)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nomeRotaController,
            decoration: InputDecoration(
              hintText: 'Nome da Rota (Ex: Rota Helder Cordeiro)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ruasController,
            decoration: InputDecoration(
              hintText: 'Ruas Atendidas (Ex: Av. Santo Antônio, Centro...)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),

          // SELETOR DO MOTORISTA DA ROTA
          DropdownButtonFormField<Motorista>(
            value: _motoristaSelecionadoParaRota,
            decoration: InputDecoration(
              hintText: 'Selecione o Motorista Responsável',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              prefixIcon: const Icon(Icons.person, color: Color(0xFF1E9C49)),
            ),
            items: listaMotoristasGlobais.map((motorista) {
              return DropdownMenuItem<Motorista>(
                value: motorista,
                child: Text('${motorista.nome} (${motorista.caminhao})'),
              );
            }).toList(),
            onChanged: (motorista) {
              setState(() {
                _motoristaSelecionadoParaRota = motorista;
              });
            },
          ),
          const SizedBox(height: 12),

          // SELETOR DE DATA E HORA
          InkWell(
            onTap: () async {
              final data = await _selecionarDataHora(context);
              if (data != null) {
                setState(() => _dataHoraSelecionada = data);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: Color(0xFF1E9C49)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _dataHoraSelecionada == null
                          ? 'Clique para selecionar Data e Hora'
                          : 'Data/Hora: ${_dataHoraSelecionada!.day}/${_dataHoraSelecionada!.month} às ${_dataHoraSelecionada!.hour}:${_dataHoraSelecionada!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: _dataHoraSelecionada == null ? Colors.grey.shade700 : Colors.black,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E9C49),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: _cadastrarRota,
              child: const Text('CADASTRAR ROTA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const Text('Rotas Ativas Cadastradas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          listaRotasGlobais.isEmpty
              ? const Text('Nenhuma rota cadastrada no momento.', style: TextStyle(color: Colors.grey))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listaRotasGlobais.length,
                  itemBuilder: (context, index) {
                    final rota = listaRotasGlobais[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.alt_route, color: Color(0xFF1E9C49), size: 30),
                        title: Text(rota.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${rota.ruas}\n'
                          'Motorista: ${rota.motoristaNome}\n'
                          'Horário: ${rota.horario}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Editar Rota',
                              onPressed: () => _abrirModalEditarRota(rota, index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Excluir Rota',
                              onPressed: () {
                                setState(() => listaRotasGlobais.removeAt(index));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // ABA 2: CADASTRO E EDIÇÃO DE MOTORISTAS
  Widget _buildTelaMotoristas() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cadastrar Motorista',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E9C49)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nomeMotoristaController,
            decoration: InputDecoration(
              hintText: 'Nome do Motorista',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cpfController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'CPF do Motorista (Somente Números)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _caminhaoController,
            decoration: InputDecoration(
              hintText: 'Número / Nome do Caminhão',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _senhaController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Senha de Acesso do Motorista',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E9C49),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: _cadastrarMotorista,
              child: const Text('CADASTRAR MOTORISTA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const Text('Motoristas Cadastrados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          listaMotoristasGlobais.isEmpty
              ? const Text('Nenhum motorista cadastrado.', style: TextStyle(color: Colors.grey))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listaMotoristasGlobais.length,
                  itemBuilder: (context, index) {
                    final motorista = listaMotoristasGlobais[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Color(0xFF1E9C49), size: 30),
                        title: Text(motorista.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('CPF: ${motorista.cpf} | Senha: ${motorista.senha}\nCaminhão: ${motorista.caminhao}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Editar Motorista',
                              onPressed: () => _abrirModalEditarMotorista(motorista, index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Excluir Motorista',
                              onPressed: () {
                                setState(() => listaMotoristasGlobais.removeAt(index));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // ABA 3: MAPA COM CAMINHÕES EM GARANHUNS PE
  Widget _buildTelaAcompanhamento() {
    // Gerar marcadores de caminhão dinamicamente para cada rota cadastrada
    final List<Marker> marcadoresCaminhoes = [];

    for (int i = 0; i < listaRotasGlobais.length; i++) {
      final rota = listaRotasGlobais[i];
      // Pega uma coordenada de Garanhuns com base no índice da rota
      final posicao = _pontosGaranhuns[i % _pontosGaranhuns.length];

      marcadoresCaminhoes.add(
        Marker(
          width: 60.0,
          height: 60.0,
          point: posicao,
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_shipping, color: Color(0xFF1E9C49), size: 32),
                          const SizedBox(width: 10),
                          Text(
                            rota.nome,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Motorista: ${rota.motoristaNome}', style: const TextStyle(fontSize: 15)),
                      Text('Ruas: ${rota.ruas}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      Text('Horário Previsto: ${rota.horario}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E9C49),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_shipping,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: _coordenadaGaranhuns,
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.coleta_de_lixo',
            ),
            MarkerLayer(markers: marcadoresCaminhoes),
          ],
        ),
        if (listaRotasGlobais.isEmpty)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: const Text(
                'Cadastre uma Rota e atribua a um Motorista para ver o caminhão no mapa de Garanhuns!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ),
      ],
    );
  }
}