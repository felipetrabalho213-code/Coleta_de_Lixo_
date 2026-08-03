import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../controllers/truck_controller.dart'; // Verifique se o caminho da pasta bate com o seu projeto

class TruckPage extends StatefulWidget {
  const TruckPage({super.key});

  @override
  State<TruckPage> createState() => _TruckPageState();
}

class _TruckPageState extends State<TruckPage> {
  final MapController _controladorMapa = MapController();
  final TruckController _controller = TruckController();

  // 📍 Posição inicial em Garanhuns - PE
  late LatLng _posicaoCaminhao;

  @override
  void initState() {
    super.initState();
    // Inicia o caminhão no primeiro ponto da rota
    _posicaoCaminhao = _controller.rotaGaranhuns.first;

    // Inicia a animação de movimento
    _controller.iniciarSimulacao((novaPosicao) {
      if (mounted) {
        setState(() {
          _posicaoCaminhao = novaPosicao;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.pararSimulacao();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ver Caminhão"),
        backgroundColor: const Color(0xFF006B4F),
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        mapController: _controladorMapa,
        options: MapOptions(
          initialCenter: _posicaoCaminhao,
          initialZoom: 16,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          // 🗺️ Mapa gratuito do OpenStreetMap
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "segue_coleta",
          ),

          // 🛤️ Linha traçada mostrando o trajeto em Garanhuns
          PolylineLayer(
            polylines: [
              Polyline(
                points: _controller.rotaGaranhuns,
                strokeWidth: 4.0,
                color: const Color(0xFF006B4F).withOpacity(0.7),
              ),
            ],
          ),

          // 🚛 Marcador animado do caminhão
          MarkerLayer(
            markers: [
              Marker(
                point: _posicaoCaminhao,
                width: 50,
                height: 50,
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_shipping, // Ícone do caminhão
                    color: Color(0xFF006B4F),
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}