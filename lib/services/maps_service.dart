import 'package:latlong2/latlong.dart';

class MapsService {
  // URL base dos mapas do OpenStreetMap
  static const String mapTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String userAgent = 'com.example.segue_coleta';

  // Exemplo de busca de posição do caminhão
  Future<LatLng> obterPosicaoCaminhao() async {
    // Aqui você faria a chamada HTTP para sua API/Firebase real
    return const LatLng(-8.1150, -35.0090);
  }
}