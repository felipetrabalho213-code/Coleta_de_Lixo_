import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/calendar_controller.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Instância do Controller
  final CalendarController _controller = CalendarController();

  CalendarFormat _formato = CalendarFormat.month;
  
  // ✅ FORÇA USAR A DATA LOCAL DO APARELHO (BRASIL)
  DateTime _diaSelecionado = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _mesAtual = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);

  String _ruaSelecionada = "Clique em uma data para ver a rota";
  String _horarioPassagem = "--:--";

  void _atualizarRota(DateTime data) {
    final rotaInfo = _controller.obterRotaPorData(data);
    setState(() {
      _ruaSelecionada = rotaInfo["rua"]!;
      _horarioPassagem = rotaInfo["horario"]!;
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
                  content: Text(
                      "Rota: $_ruaSelecionada • Horário: $_horarioPassagem"),
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