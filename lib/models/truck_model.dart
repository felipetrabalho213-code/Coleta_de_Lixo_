class TruckModel {
  final double latitude;
  final double longitude;
  final String placa;

  TruckModel({
    required this.latitude,
    required this.longitude,
    this.placa = '',
  });
}