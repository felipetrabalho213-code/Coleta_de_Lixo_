import 'package:flutter/material.dart';

// Import com caminho relativo correto
import '../../models/app_state.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({Key? key}) : super(key: key);

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  bool _emAndamento = false;

  @override
  Widget build(BuildContext context) {
    final motorista = motoristaLogadoGlobal;

    // Filtra para exibir APENAS as rotas destinadas ao motorista conectado
    final minhasRotas = listaRotasGlobais.where((rota) {
      if (motorista == null) return false;
      final cpfRota = rota.motoristaCpf.replaceAll(RegExp(r'\D'), '');
      final cpfMotorista = motorista.cpf.replaceAll(RegExp(r'\D'), '');
      return cpfRota == cpfMotorista;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(motorista != null ? 'Painel: ${motorista.nome}' : 'Painel do Motorista'),
        backgroundColor: const Color(0xFF1E9C49),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              motoristaLogadoGlobal = null;
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card com Informações do Motorista Logado
            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(Icons.local_shipping, size: 40, color: Color(0xFF1E9C49)),
                title: Text(
                  motorista?.nome ?? 'Motorista Desconhecido',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Veículo: ${motorista?.caminhao ?? "Não atrelado"}\nCPF: ${motorista?.cpf ?? ""}'),
              ),
            ),
            const SizedBox(height: 20),

            // Botão de Status da Coleta
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _emAndamento ? Colors.orange : const Color(0xFF1E9C49),
                ),
                icon: Icon(_emAndamento ? Icons.pause : Icons.play_arrow, color: Colors.white),
                label: Text(
                  _emAndamento ? 'PAUSAR COLETA' : 'INICIAR COLETA DA ROTA',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  setState(() {
                    _emAndamento = !_emAndamento;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Suas Rotas Atribuídas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E9C49)),
            ),
            const SizedBox(height: 10),

            // Lista de Rotas Filtradas
            Expanded(
              child: minhasRotas.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma rota foi atribuída a você no momento pelo Admin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: minhasRotas.length,
                      itemBuilder: (context, index) {
                        final rota = minhasRotas[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.alt_route, color: Color(0xFF1E9C49)),
                            title: Text(
                              rota.nome,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Ruas: ${rota.ruas}\nHorário: ${rota.horario}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}