import 'package:latlong2/latlong.dart';
import '../services/maps_service.dart';

class MapController {
  final MapsService _mapsService = MapsService();

  // Posição padrão
  final LatLng posicaoInicial = const LatLng(-8.890727456058368, -36.49433579689482);
  LatLng? posicaoCaminhao;

  Future<void> carregarCaminhao() async {
    posicaoCaminhao = await _mapsService.obterPosicaoCaminhao();
  }
}