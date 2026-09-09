import 'package:flutter/material.dart';
import '../../models/app_state.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

enum TipoColetaDia {
  ruaUsuario, // Bolinha Verde
  outraRua,   // Bolinha Cinza
  nenhuma     // Sem cor
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _mesAtual;
  late DateTime _diaSelecionado;

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    _mesAtual = DateTime(hoje.year, hoje.month, 1);
    _diaSelecionado = DateTime(hoje.year, hoje.month, hoje.day);
  }

  String _normalizarTexto(String texto) {
    return texto
        .toLowerCase()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c');
  }

  bool _rotaAtendeUsuario(Rota rota, String enderecoUsuario) {
    if (enderecoUsuario.trim().isEmpty) return false;
    final enderecoNorm = _normalizarTexto(enderecoUsuario);
    final ruasNorm = _normalizarTexto(rota.ruas);

    final palavrasUsuario = enderecoNorm
        .split(RegExp(r'[\s,-]+'))
        .where((t) => t.length > 2 && t != 'rua' && t != 'avenida' && t != 'bairro');

    for (var palavra in palavrasUsuario) {
      if (ruasNorm.contains(palavra)) {
        return true;
      }
    }
    return false;
  }

  TipoColetaDia _obterTipoColetaDia(DateTime dia) {
    bool temOutraRua = false;
    final enderecoUser = usuarioLogadoGlobal?.endereco ?? '';

    for (var rota in listaRotasGlobais) {
      // 1. Checagem por Data Exata (se cadastrado via calendário no ADM)
      if (rota.dataExata != null) {
        if (rota.dataExata!.year == dia.year &&
            rota.dataExata!.month == dia.month &&
            rota.dataExata!.day == dia.day) {
          if (_rotaAtendeUsuario(rota, enderecoUser)) {
            return TipoColetaDia.ruaUsuario;
          } else {
            temOutraRua = true;
          }
        }
      } else {
        // 2. Checagem por Dia da Semana em Texto (compatibilidade)
        final horarioLower = _normalizarTexto(rota.horario);
        final ruasLower = _normalizarTexto(rota.ruas);
        final combinacaoTexto = '$horarioLower $ruasLower';

        for (var entry in diasSemanaMap.entries) {
          if (combinacaoTexto.contains(entry.key) && dia.weekday == entry.value) {
            if (_rotaAtendeUsuario(rota, enderecoUser)) {
              return TipoColetaDia.ruaUsuario;
            } else {
              temOutraRua = true;
            }
          }
        }
      }
    }

    return temOutraRua ? TipoColetaDia.outraRua : TipoColetaDia.nenhuma;
  }

  List<Rota> _obterRotasDoDia(DateTime dia) {
    List<Rota> rotas = [];
    final enderecoUser = usuarioLogadoGlobal?.endereco ?? '';

    for (var rota in listaRotasGlobais) {
      if (rota.dataExata != null) {
        if (rota.dataExata!.year == dia.year &&
            rota.dataExata!.month == dia.month &&
            rota.dataExata!.day == dia.day) {
          rotas.add(rota);
        }
      } else {
        final horarioLower = _normalizarTexto(rota.horario);
        final ruasLower = _normalizarTexto(rota.ruas);
        final combinacaoTexto = '$horarioLower $ruasLower';

        for (var entry in diasSemanaMap.entries) {
          if (combinacaoTexto.contains(entry.key) && dia.weekday == entry.value) {
            if (!rotas.contains(rota)) rotas.add(rota);
          }
        }
      }
    }
    return rotas;
  }

  @override
  Widget build(BuildContext context) {
    final diasNoMes = DateUtils.getDaysInMonth(_mesAtual.year, _mesAtual.month);
    final primeiroDiaDoMes = DateTime(_mesAtual.year, _mesAtual.month, 1);
    final offsetInicio = primeiroDiaDoMes.weekday % 7;

    final rotasDoDiaSelecionado = _obterRotasDoDia(_diaSelecionado);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Calendário de Coleta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF006B4F),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          children: [
            // Controle Mês
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.black87),
                  onPressed: () {
                    setState(() {
                      _mesAtual = DateTime(_mesAtual.year, _mesAtual.month - 1);
                    });
                  },
                ),
                Text(
                  '${_getNombreMes(_mesAtual.month)} de ${_mesAtual.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004D36),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '2 weeks',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.black87),
                  onPressed: () {
                    setState(() {
                      _mesAtual = DateTime(_mesAtual.year, _mesAtual.month + 1);
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Cabeçalho dos Dias da Semana (Sintaxe Linha 161 corrigida aqui)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('dom.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('seg.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('ter.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('qua.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('qui.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('sex.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('sáb.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),

            const SizedBox(height: 12),

            // Grade dos Dias
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: diasNoMes + offsetInicio,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                if (index < offsetInicio) {
                  return const SizedBox();
                }

                final diaNumero = index - offsetInicio + 1;
                final dataCorrente = DateTime(_mesAtual.year, _mesAtual.month, diaNumero);
                final tipoColeta = _obterTipoColetaDia(dataCorrente);
                final isSelecionado = _diaSelecionado.year == dataCorrente.year &&
                    _diaSelecionado.month == dataCorrente.month &&
                    _diaSelecionado.day == dataCorrente.day;

                Color? corFundo;
                Color corTexto = Colors.black87;

                if (tipoColeta == TipoColetaDia.ruaUsuario) {
                  corFundo = const Color(0xFF006B4F); // VERDE
                  corTexto = Colors.white;
                } else if (tipoColeta == TipoColetaDia.outraRua) {
                  corFundo = Colors.grey.shade400;     // CINZA
                  corTexto = Colors.white;
                } else if (isSelecionado) {
                  corFundo = const Color(0xFF006B4F).withOpacity(0.2);
                  corTexto = const Color(0xFF006B4F);
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _diaSelecionado = dataCorrente;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: corFundo,
                      shape: BoxShape.circle,
                      border: isSelecionado && tipoColeta == TipoColetaDia.nenhuma
                          ? Border.all(color: const Color(0xFF006B4F), width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$diaNumero',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: corTexto,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            Text(
              'Data: ${_diaSelecionado.day}/${_diaSelecionado.month}/${_diaSelecionado.year}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006B4F),
              ),
            ),

            const SizedBox(height: 12),

            if (rotasDoDiaSelecionado.isNotEmpty) ...[
              ...rotasDoDiaSelecionado.map((rota) {
                final eRuaDoUsuario = _rotaAtendeUsuario(
                  rota,
                  usuarioLogadoGlobal?.endereco ?? '',
                );

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEFEF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        rota.nome.isNotEmpty ? rota.nome : 'Rota de Coleta',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: eRuaDoUsuario ? const Color(0xFF006B4F) : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rota.ruas,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Garanhuns - PE',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('⏰ ', style: TextStyle(fontSize: 14)),
                          Text(
                            'Horário previsto: ${rota.horario}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006B4F),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEFEF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Nenhuma rota cadastrada para esta data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getNombreMes(int mes) {
    const meses = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return meses[mes - 1];
  }
}