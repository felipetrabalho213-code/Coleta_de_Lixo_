import 'dart:async';
import 'package:latlong2/latlong.dart';

class TruckController {
  // 📍 Rota simulada do caminhão passando por ruas de Garanhuns - PE
  final List<LatLng> rotaGaranhuns = const [
    LatLng(-8.890727, -36.494335),
    LatLng(-8.891200, -36.493800),
    LatLng(-8.892000, -36.492900),
    LatLng(-8.893100, -36.492000),
    LatLng(-8.894000, -36.491200),
    LatLng(-8.894800, -36.490500),
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