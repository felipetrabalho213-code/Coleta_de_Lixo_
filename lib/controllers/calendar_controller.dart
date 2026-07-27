class CalendarController {
  // 📜 Ruas e horários de Garanhuns - PE
  final List<Map<String, String>> rotasGaranhuns = const [
    {"rua": "Rua Marechal Deodoro", "horario": "07h30"},
    {"rua": "Rua Barão de Lucena", "horario": "08h00"},
    {"rua": "Rua da Conceição", "horario": "08h30"},
    {"rua": "Rua Siqueira Campos", "horario": "09h00"},
    {"rua": "Rua Duque de Caxias", "horario": "09h30"},
    {"rua": "Rua Floriano Peixoto", "horario": "10h00"},
    {"rua": "Rua Gonçalves Dias", "horario": "10h30"},
    {"rua": "Rua Primeiro de Março", "horario": "11h00"},
    {"rua": "Rua Quinze de Novembro", "horario": "11h30"},
    {"rua": "Rua São José", "horario": "13h00"},
    {"rua": "Rua Santo Antônio", "horario": "13h30"},
    {"rua": "Rua Tiradentes", "horario": "14h00"},
    {"rua": "Rua Visconde de Rio Branco", "horario": "14h30"},
    {"rua": "Rua Prudente de Morais", "horario": "15h00"},
    {"rua": "Rua Deodoro da Fonseca", "horario": "15h30"},
    {"rua": "Rua Getúlio Vargas", "horario": "16h00"},
    {"rua": "Avenida Rui Barbosa", "horario": "16h30"},
    {"rua": "Avenida Agamenon Magalhães", "horario": "17h00"},
    {"rua": "Avenida Frei Damião", "horario": "17h30"},
    {"rua": "Avenida Souza Filho", "horario": "18h00"},
  ];

  // Lógica para obter a rota do dia selecionado
  Map<String, String> obterRotaPorData(DateTime data) {
    int indice = data.day % rotasGaranhuns.length;
    return rotasGaranhuns[indice];
  }
}