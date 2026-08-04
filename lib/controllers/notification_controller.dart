import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends ChangeNotifier {
  static final NotificationController instance = NotificationController._internal();
  NotificationController._internal() {
    _carregarEstado();
  }

  static const String _storageKeyNotificacoes = 'historico_notificacoes_coleta';
  static const String _storageKeyAtivado = 'notificacoes_ativas_coleta';
  static const String _topicoPadrao = 'garanhuns_coleta';

  final List<Map<String, String>> _notificacoes = [];
  bool _notificacoesAtivas = true;

  List<Map<String, String>> get notificacoes => List.unmodifiable(_notificacoes);
  bool get notificacoesAtivas => _notificacoesAtivas;

  Future<void> alternarNotificacoes(bool ativar) async {
    _notificacoesAtivas = ativar;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKeyAtivado, ativar);

    if (ativar) {
      await FirebaseMessaging.instance.subscribeToTopic(_topicoPadrao);
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic(_topicoPadrao);
    }
  }

  Future<void> adicionarNotificacaoFirebase(RemoteMessage message) async {
    if (!_notificacoesAtivas) return;

    final title = message.notification?.title ?? 'Aviso da Coleta';
    final body = message.notification?.body ?? 'Nova atualização sobre o serviço.';

    // 📍 Força a conversão para o Fuso Horário do Brasil (GMT-3)
    DateTime dataNotificacao = message.sentTime ?? DateTime.now();
    DateTime dataBrasil = dataNotificacao.toUtc().subtract(const Duration(hours: 3));

    // Formata no padrão ISO (Ano-Mês-Dia Hora:Minuto)
    final String dateFormatted = dataBrasil.toString().substring(0, 16);

    _notificacoes.insert(0, {
      'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'date': dateFormatted,
    });

    notifyListeners();
    await _salvarNotificacoes();
  }

  Future<void> removerNotificacao(String id) async {
    _notificacoes.removeWhere((item) => item['id'] == id);
    notifyListeners();
    await _salvarNotificacoes();
  }

  Future<void> limparTodas() async {
    _notificacoes.clear();
    notifyListeners();
    await _salvarNotificacoes();
  }

  Future<void> _salvarNotificacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final String dataJson = jsonEncode(_notificacoes);
    await prefs.setString(_storageKeyNotificacoes, dataJson);
  }

  Future<void> _carregarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    _notificacoesAtivas = prefs.getBool(_storageKeyAtivado) ?? true;

    final String? dataJson = prefs.getString(_storageKeyNotificacoes);
    if (dataJson != null && dataJson.isNotEmpty) {
      final List<dynamic> decodedList = jsonDecode(dataJson);
      _notificacoes.clear();
      for (var item in decodedList) {
        _notificacoes.add(Map<String, String>.from(item));
      }
    }
    notifyListeners();
  }
}