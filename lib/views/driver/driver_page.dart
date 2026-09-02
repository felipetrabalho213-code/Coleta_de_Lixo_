import 'package:flutter/material.dart';
import '../admin/admin_page.dart'; // Importa a classe Motorista e as listas globais

class DriverPage extends StatefulWidget {
  final Motorista motorista;

  const DriverPage({super.key, required this.motorista});

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  bool transmisaoAtiva = false;

  void _exibirListaRotas(BuildContext context) {
    // Filtra apenas as rotas destinadas a este motorista
    final rotasDoMotorista = listaRotasGlobais
        .where((r) => r.cpfMotorista == widget.motorista.cpf)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Minhas Rotas Atribuídas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006B4F),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              rotasDoMotorista.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(
                          'Nenhuma rota cadastrada para você no momento.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rotasDoMotorista.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final rota = rotasDoMotorista[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF006B4F).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    rota.nome,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF006B4F).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Ativa',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF006B4F),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ruas: ${rota.ruas}',
                                style: TextStyle(color: Colors.grey[700], fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                rota.horario,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtra a primeira rota deste motorista para mostrar no resumo do card
    final rotasDoMotorista = listaRotasGlobais
        .where((r) => r.cpfMotorista == widget.motorista.cpf)
        .toList();
    final rotaAtual = rotasDoMotorista.isNotEmpty ? rotasDoMotorista.first : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Painel do Motorista'),
        backgroundColor: const Color(0xFF006B4F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Perfil do Motorista Logado
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(Icons.person, size: 60, color: Color(0xFF757575)),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF006B4F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.motorista.nome,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.motorista.caminhao,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // Card Transmissão
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transmisaoAtiva ? 'Transmissão Ativa' : 'Transmissão Desativada',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Ligue ao iniciar sua jornada',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  Switch(
                    value: transmisaoAtiva,
                    activeColor: const Color(0xFF006B4F),
                    onChanged: (val) {
                      setState(() => transmisaoAtiva = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Card Rota do Dia (Dinâmico)
            Material(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _exibirListaRotas(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.alt_route, color: Color(0xFF006B4F)),
                              SizedBox(width: 8),
                              Text(
                                'Sua Rota do Dia',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF006B4F),
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      const Divider(height: 24),
                      if (rotaAtual != null) ...[
                        Text(
                          '• ${rotaAtual.nome}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ruas: ${rotaAtual.ruas}',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          rotaAtual.horario,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ] else ...[
                        const Text(
                          'Nenhuma rota ativa no momento.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Dados do Motorista Logado
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Meus Dados',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildDadoItem(
                    icon: Icons.person_outline,
                    label: 'Nome Completo',
                    valor: widget.motorista.nome,
                  ),
                  const Divider(height: 20),
                  _buildDadoItem(
                    icon: Icons.badge_outlined,
                    label: 'CPF / Matrícula',
                    valor: widget.motorista.cpf,
                  ),
                  const Divider(height: 20),
                  _buildDadoItem(
                    icon: Icons.local_shipping_outlined,
                    label: 'Caminhão Atribuído',
                    valor: widget.motorista.caminhao,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDadoItem({
    required IconData icon,
    required String label,
    required String valor,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF006B4F), size: 22),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              valor,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}