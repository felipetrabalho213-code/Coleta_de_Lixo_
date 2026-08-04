import 'package:flutter/foundation.dart';

// Modelo simples para representar cada ponto da rota no dia
class RotaItem {
  final String rua;
  final String bairro;
  final String horario;

  RotaItem({
    required this.rua,
    required this.bairro,
    required this.horario,
  });
}

class CalendarController extends ChangeNotifier {
  static final CalendarController instance = CalendarController._internal();
  CalendarController._internal();

  DateTime _diaSelecionado = DateTime.now();
  DateTime get diaSelecionado => _diaSelecionado;

  void selecionarDia(DateTime dia) {
    _diaSelecionado = dia;
    notifyListeners();
  }

  // Retorna a lista de 4 ruas/horários baseada no dia selecionado
  List<RotaItem> obterRotasDoDia(DateTime dia) {
    // Exemplo dinâmico: podemos alternar os horários e ruas dependendo do dia
    final int diaDaSemana = dia.weekday;

    if (diaDaSemana % 2 == 0) {
      return [
        RotaItem(rua: 'Rua Siqueira Campos', bairro: 'Santo Antônio', horario: '08:00'),
        RotaItem(rua: 'Rua Dantas Barreto', bairro: 'Santo Antônio', horario: '09:30'),
        RotaItem(rua: 'Av. Rui Barbosa', bairro: 'Heliópolis', horario: '11:00'),
        RotaItem(rua: 'Rua Santos Dumont', bairro: 'Heliópolis', horario: '14:00'),
      ];
    } else {
      return [
        RotaItem(rua: 'Rua Rosa Branca', bairro: 'Boa Vista', horario: '07:30'),
        RotaItem(rua: 'Rua Nilo Peçanha', bairro: 'Boa Vista', horario: '09:00'),
        RotaItem(rua: 'Rua Dr. José Mariano', bairro: 'Centro', horario: '10:30'),
        RotaItem(rua: 'Rua Treze de Maio', bairro: 'Centro', horario: '13:30'),
      ];
    }
  }
}