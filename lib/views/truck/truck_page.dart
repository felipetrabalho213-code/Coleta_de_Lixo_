import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TruckPage extends StatefulWidget {
  const TruckPage({super.key});

  @override
  State<TruckPage> createState() => _TruckPageState();
}

class _TruckPageState extends State<TruckPage> {
  final MapController _controladorMapa = MapController();

  // 📍 Posição inicial: Jaboatão dos Guararapes - PE
  final LatLng _posicaoInicial = const LatLng(-8.890727456058368, -36.49433579689482);
  final LatLng _posicaoCaminhao = const LatLng(-8.1150, -35.0090);

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
          initialCenter: _posicaoInicial,
          initialZoom: 15,
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

          // 🛤️ Linha da rota do caminhão
        

          // 🚛 Marcador do caminhão
        
        ],
      ),
    );
  }
}