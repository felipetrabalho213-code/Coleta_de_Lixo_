import 'package:flutter/material.dart';
import '../../controllers/notification_controller.dart';
import '../../utils/app_colors.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

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
          final notificacoes = NotificationController.instance.notificacoes;

          if (notificacoes.isEmpty) {
            return Center(
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
                      child: Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.green.withOpacity(0.1),                      ),
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
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notificacoes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final aviso = notificacoes[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.notifications_active,
                      color: Colors.green.withOpacity(0.1),
                    ),
                  ),
                  title: Text(
                    aviso['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      aviso['body'] ?? '',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      if (aviso['id'] != null) {
                        NotificationController.instance.removerNotificacao(aviso['id']!);
                      }
                    },
                  ),
                ),
              );
            },
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