import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../models/app_state.dart';

class TruckPage extends StatefulWidget {
  const TruckPage({Key? key}) : super(key: key);

  @override
  State<TruckPage> createState() => _TruckPageState();
}

class _TruckPageState extends State<TruckPage> {
  final MapController _mapController = MapController();

  // Localização Padrão de Recuo (Centro de Garanhuns - PE)
  LatLng _localizacaoUsuario = const LatLng(-8.8828, -36.4967);
  LatLng _localizacaoCaminhaoProximo = const LatLng(-8.8850, -36.4930);

  bool _permissaoConcedida = false;
  bool _carregandoCoordenadas = false;

  @override
  void initState() {
    super.initState();
    if (usuarioLogadoGlobal != null) {
      _permissaoConcedida = true;
      _buscarCoordenadasPorEndereco();
    }
  }

  // Converte o endereço digitado pelo usuário em coordenadas GPS reais
  Future<void> _buscarCoordenadasPorEndereco() async {
    final usuario = usuarioLogadoGlobal;
    if (usuario == null || usuario.endereco.isEmpty) return;

    setState(() => _carregandoCoordenadas = true);

    // Garante a inclusão do município e estado para maior precisão
    String enderecoCompleto = usuario.endereco;
    if (!enderecoCompleto.toLowerCase().contains('garanhuns')) {
      enderecoCompleto += ', Garanhuns - PE';
    }

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(enderecoCompleto)}&format=json&limit=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'SegueColetaApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final double lat = double.parse(data[0]['lat']);
          final double lon = double.parse(data[0]['lon']);

          setState(() {
            _localizacaoUsuario = LatLng(lat, lon);
            // Posiciona o caminhão fictício perto da localização real da casa do usuário
            _localizacaoCaminhaoProximo = LatLng(lat - 0.0020, lon + 0.0025);
          });

          // Centraliza o mapa na casa do usuário
          _mapController.move(_localizacaoUsuario, 16.0);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Endereço exato não localizado no mapa. Exibindo região central.'),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Trata possíveis falhas de conexão de rede
    } finally {
      if (mounted) {
        setState(() => _carregandoCoordenadas = false);
      }
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
            child: const Text('NEGAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B4F)),
            onPressed: () {
              setState(() {
                _permissaoConcedida = true;
              });
              Navigator.pop(context);
              _buscarCoordenadasPorEndereco();
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
            mapController: _mapController,
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
                                const Text('Previsão de Passagem: ~15 a 20 minutos'),
                                const Text('Rota: Setor Centro / Heliópolis / Magano'),
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

          // INDICADOR DE CARREGAMENTO DO ENDEREÇO
          if (_carregandoCoordenadas)
            Positioned(
              top: 130,
              left: 20,
              right: 20,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF006B4F),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Localizando o seu endereço no mapa...',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                              Expanded(
                                child: Text(
                                  'Caminhão mais próximo a 600m da sua localização.',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: const [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 10),
                          Expanded(
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

          // BOTÃO FLUTUANTE PARA SOLICITAR PERMISSÃO DE GPS
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