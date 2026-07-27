class CalendarModel {
  final String diaSemana;
  final String horario;
  final String tipoColeta;
  final bool ativoHoje;

  CalendarModel({
    required this.diaSemana,
    required this.horario,
    required this.tipoColeta,
    this.ativoHoje = false,
  });
}