import 'package:flutter/material.dart';
import '../../controllers/notification_controller.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  // Função auxiliar para formatar a data (transforma 2026-08-03 em 03/08/2026)
  String _formatarData(String? dateString) {
    if (dateString == null || dateString.length < 10) return '';
    try {
      final partesData = dateString.substring(0, 10).split('-'); // [2026, 08, 03]
      if (partesData.length == 3) {
        return '${partesData[2]}/${partesData[1]}/${partesData[0]}'; // 03/08/2026
      }
    } catch (_) {}
    return '';
  }

  // Função auxiliar para extrair a hora (HH:mm)
  String _formatarHora(String? dateString) {
    if (dateString == null || dateString.length < 16) return '';
    return dateString.substring(11, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histórico de Avisos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Ícone para ativar/desativar notificações
          AnimatedBuilder(
            animation: NotificationController.instance,
            builder: (context, _) {
              final ativadas = NotificationController.instance.notificacoesAtivas;
              return IconButton(
                icon: Icon(
                  ativadas ? Icons.notifications_active : Icons.notifications_off_outlined,
                  color: Colors.white,
                ),
                tooltip: ativadas ? 'Desativar avisos' : 'Ativar avisos',
                onPressed: () {
                  NotificationController.instance.alternarNotificacoes(!ativadas);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        !ativadas
                            ? 'Notificações ativadas com sucesso!'
                            : 'Notificações pausadas.',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
          // Ícone para limpar o histórico
          AnimatedBuilder(
            animation: NotificationController.instance,
            builder: (context, _) {
              if (NotificationController.instance.notificacoes.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.white),
                tooltip: 'Limpar tudo',
                onPressed: () {
                  _confirmarLimpezaGeral(context);
                },
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: NotificationController.instance,
        builder: (context, child) {
          final controller = NotificationController.instance;
          final notificacoes = controller.notificacoes;
          final ativadas = controller.notificacoesAtivas;

          return Column(
            children: [
              if (!ativadas)
                Container(
                  width: double.infinity,
                  color: Colors.amber.shade100,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Avisos temporariamente desativados neste aparelho.',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: notificacoes.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_none,
                                  size: 64,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Nenhum aviso no momento',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Quando houver comunicados sobre a coleta ou o caminhão estiver se aproximando, os avisos enviados pelo sistema aparecerão aqui.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: notificacoes.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final aviso = notificacoes[index];
                          final dateString = aviso['date'];

                          final horaFormatada = _formatarHora(dateString);
                          final dataFormatada = _formatarData(dateString);

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green.withOpacity(0.15),
                                    child: const Icon(
                                      Icons.notifications_active,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                aviso['title'] ?? '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // 📍 Data em cima (maior) e Hora em baixo
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                if (dataFormatada.isNotEmpty)
                                                  Text(
                                                    dataFormatada,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                if (horaFormatada.isNotEmpty)
                                                  Text(
                                                    horaFormatada,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.black45,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          aviso['body'] ?? '',
                                          style: const TextStyle(color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () {
                                      if (aviso['id'] != null) {
                                        NotificationController.instance.removerNotificacao(aviso['id']!);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmarLimpezaGeral(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar Histórico'),
        content: const Text('Deseja apagar todos os avisos do histórico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              NotificationController.instance.limparTodas();
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}