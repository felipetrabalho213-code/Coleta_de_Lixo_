import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/app_state.dart';

class TruckPage extends StatefulWidget {
  const TruckPage({Key? key}) : super(key: key);

  @override
  State<TruckPage> createState() => _TruckPageState();
}

class _TruckPageState extends State<TruckPage> {
  // Localização Padrão (Centro de Garanhuns - PE)
  LatLng _localizacaoUsuario = const LatLng(-8.8828, -36.4967);
  bool _permissaoConcedida = false;

  // Localização Fictícia do Caminhão Próximo à Casa do Cidadão (Garanhuns)
  final LatLng _localizacaoCaminhaoProximo = const LatLng(-8.8850, -36.4930);

  @override
  void initState() {
    super.initState();
    // Se o usuário estiver logado, podemos ajustar ligeiramente as coordenadas para simular seu endereço
    if (usuarioLogadoGlobal != null) {
      _permissaoConcedida = true;
    }
  }

  void _solicitarPermissaoLocalizacao() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Color(0xFF006B4F)),
            SizedBox(width: 8),
            Text('Permissão de Localização'),
          ],
        ),
        content: const Text(
          'O "Segue Coleta" precisa da sua localização para mostrar os caminhões em rota perto do seu endereço cadastrado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NEGARI', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B4F)),
            onPressed: () {
              setState(() {
                _permissaoConcedida = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Localização ativada! Exibindo rota do caminhão próximo.'),
                  backgroundColor: Color(0xFF006B4F),
                ),
              );
            },
            child: const Text('PERMITIR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = usuarioLogadoGlobal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acompanhar Caminhão'),
        backgroundColor: const Color(0xFF006B4F),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // MAPA DE GARANHUNS
          FlutterMap(
            options: MapOptions(
              initialCenter: _localizacaoUsuario,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.coleta_de_lixo',
              ),
              MarkerLayer(
                markers: [
                  // MARCADOR 1: CASA DO CIDADÃO LOGADO
                  if (usuario != null)
                    Marker(
                      width: 50.0,
                      height: 50.0,
                      point: _localizacaoUsuario,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Sua Residência: ${usuario.endereco}'),
                              backgroundColor: const Color(0xFF006B4F),
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          child: const Icon(Icons.home, color: Colors.white, size: 28),
                        ),
                      ),
                    ),

                  // MARCADOR 2: CAMINHÃO FICTÍCIO EM ROTA PRÓXIMA
                  Marker(
                    width: 55.0,
                    height: 55.0,
                    point: _localizacaoCaminhaoProximo,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.local_shipping, color: Color(0xFF006B4F), size: 30),
                                    SizedBox(width: 10),
                                    Text(
                                      'Caminhão em Rota Próxima',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Status: Em atendimento na sua região',
                                  style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text('Previsão de Passagem: ~15 a 20 minutos'),
                                Text('Rota: Setor Centro / Heliópolis'),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF006B4F),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black38, blurRadius: 6),
                          ],
                        ),
                        child: const Icon(Icons.local_shipping, color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // PAINEL SUPERIOR COM DADOS DO USUÁRIO OU ALERTA DE PERMISSÃO
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: usuario != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: Color(0xFF006B4F)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Olá, ${usuario.nome}!',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              const Icon(Icons.verified, color: Colors.green, size: 20),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Endereço: ${usuario.endereco}',
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const Divider(height: 16),
                          const Row(
                            children: [
                              Icon(Icons.directions_bus, color: Color(0xFF006B4F), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Caminhão mais próximo a 600m da sua localização.',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Faça login como cidadão para vincular a rota à sua casa!',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // BOTÃO FLUTUANTE PARA SOLICITAR PERMISSÃO DE GPS (CASO NÃO TENHA CONCEDIDO)
          if (!_permissaoConcedida)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xFF006B4F),
                onPressed: _solicitarPermissaoLocalizacao,
                icon: const Icon(Icons.my_location, color: Colors.white),
                label: const Text('Ativar GPS', style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}