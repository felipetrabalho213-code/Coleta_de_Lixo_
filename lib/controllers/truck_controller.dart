import 'dart:async';
import 'package:latlong2/latlong.dart';

class TruckController {
  // 📍 Rota simulada do caminhão passando por ruas de Garanhuns - PE
  final List<LatLng> rotaGaranhuns = const [
    LatLng(-8.881697035344347, -36.485575073298534),
    LatLng(-8.881251827139229, -36.485247843826514),
    LatLng(-8.880758917424435, -36.4848776990139),
    LatLng(-8.8816440343959, -36.48443781677282),
    LatLng(-8.882931955288905, -36.483815544221194),
    LatLng(-8.88391246815539, -36.483289831284345),
    LatLng(-8.884580275441099, -36.48406230744464),  
    LatLng(-8.885534283716781, -36.48554825120652),
    ];

  int _indiceAtual = 0;
  Timer? _timer;

  // Inicia o movimento do caminhão percorrendo os pontos da lista
  void iniciarSimulacao(Function(LatLng novaPosicao) onAtualizar) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _indiceAtual = (_indiceAtual + 1) % rotaGaranhuns.length;
      onAtualizar(rotaGaranhuns[_indiceAtual]);
    });
  }

  void pararSimulacao() {
    _timer?.cancel();
  }
}