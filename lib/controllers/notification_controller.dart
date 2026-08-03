import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends ChangeNotifier {
  static final NotificationController instance = NotificationController._internal();
  NotificationController._internal() {
    _carregarNotificacoes();
  }

  static const String _storageKey = 'historico_notificacoes_coleta';
  final List<Map<String, String>> _notificacoes = [];

  List<Map<String, String>> get notificacoes => List.unmodifiable(_notificacoes);

  // 1. Adiciona e salva localmente
  Future<void> adicionarNotificacaoFirebase(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Aviso da Coleta';
    final body = message.notification?.body ?? 'Nova atualização sobre o serviço.';
    final date = DateTime.now().toString().substring(0, 16);

    _notificacoes.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'date': date,
    });

    notifyListeners();
    await _salvarNotificacoes();
  }

  // 2. Exclui uma notificação específica
  Future<void> removerNotificacao(String id) async {
    _notificacoes.removeWhere((item) => item['id'] == id);
    notifyListeners();
    await _salvarNotificacoes();
  }

  // 3. Exclui todas as notificações
  Future<void> limparTodas() async {
    _notificacoes.clear();
    notifyListeners();
    await _salvarNotificacoes();
  }

  // Persistência com SharedPreferences
  Future<void> _salvarNotificacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final String dataJson = jsonEncode(_notificacoes);
    await prefs.setString(_storageKey, dataJson);
  }

  Future<void> _carregarNotificacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataJson = prefs.getString(_storageKey);

    if (dataJson != null && dataJson.isNotEmpty) {
      final List<dynamic> decodedList = jsonDecode(dataJson);
      _notificacoes.clear();
      for (var item in decodedList) {
        _notificacoes.add(Map<String, String>.from(item));
      }
      notifyListeners();
    }
  }
}