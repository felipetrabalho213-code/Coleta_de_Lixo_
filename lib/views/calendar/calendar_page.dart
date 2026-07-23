import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _formato = CalendarFormat.month;
  // ✅ FORÇA USAR A DATA LOCAL DO APARELHO (BRASIL)
  DateTime _diaSelecionado = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _mesAtual = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  String _ruaSelecionada = "Clique em uma data para ver a rota";
  String _horarioPassagem = "--:--";

  // 📜 Ruas e horários de Garanhuns - PE
  final List<Map<String, String>> _rotasGaranhuns = [
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

  void _atualizarRota(DateTime data) {
    int indice = data.day % _rotasGaranhuns.length;
    setState(() {
      _ruaSelecionada = _rotasGaranhuns[indice]["rua"]!;
      _horarioPassagem = _rotasGaranhuns[indice]["horario"]!;
    });
  }

  @override
  void initState() {
    super.initState();
    _atualizarRota(_diaSelecionado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendário de Coleta"),
        backgroundColor: const Color(0xFF006B4F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'pt_BR',
            // ✅ Define o intervalo de datas sem usar UTC
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2030, 12, 31),
            focusedDay: _mesAtual,
            calendarFormat: _formato,
            selectedDayPredicate: (dia) => isSameDay(_diaSelecionado, dia),
            onDaySelected: (dia, focado) {
              setState(() {
                _diaSelecionado = dia;
                _mesAtual = focado;
              });
              _atualizarRota(dia);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Rota: $_ruaSelecionada • Horário: $_horarioPassagem"),
                  backgroundColor: const Color(0xFF006B4F),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onFormatChanged: (novoFormato) {
              setState(() => _formato = novoFormato);
            },
            onPageChanged: (novoMes) {
              setState(() => _mesAtual = novoMes);
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF006B4F),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: const Color(0xFF006B4F).withOpacity(0.35),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF006B4F), width: 2),
              ),
            ),
            headerStyle: const HeaderStyle(
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004B36),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  "Data: ${_diaSelecionado.day}/${_diaSelecionado.month}/${_diaSelecionado.year}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF004B36),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006B4F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Rota de Coleta",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF004B36),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _ruaSelecionada,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Garanhuns - PE",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "⏰ Horário previsto: $_horarioPassagem",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF006B4F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}