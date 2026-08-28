import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _key = 'historico_coletas';

  // Salva uma nova solicitação
  static Future<void> salvarSolicitacao({
    required String descricao,
    required String endereco,
    required String nome,
    required String telefone,
    String? imagemBase64,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, String>> historico = await carregarHistorico();

      Map<String, String> novaSolicitacao = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'descricao': descricao.isEmpty ? 'Solicitação sem título' : descricao,
        'endereco': endereco,
        'nome': nome,
        'telefone': telefone,
        'data': DateTime.now().toString(),
        'imagem': imagemBase64 ?? '',
      };

      historico.insert(0, novaSolicitacao);

      String jsonString = jsonEncode(historico);
      await prefs.setString(_key, jsonString);
    } catch (e) {
      print('❌ Erro ao salvar no SharedPreferences: $e');
    }
  }

  // Carrega a lista completa
  static Future<List<Map<String, String>>> carregarHistorico() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_key);

      if (jsonString != null && jsonString.isNotEmpty) {
        List<dynamic> listJson = jsonDecode(jsonString);
        return listJson.map((item) => Map<String, String>.from(item)).toList();
      }
    } catch (e) {
      print('❌ Erro ao carregar histórico: $e');
    }
    return [];
  }

  // Atualiza uma solicitação existente
  static Future<void> atualizarSolicitacao(int index, Map<String, String> solicitacaoAtualizada) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, String>> historico = await carregarHistorico();

      if (index >= 0 && index < historico.length) {
        historico[index] = solicitacaoAtualizada;
        String jsonString = jsonEncode(historico);
        await prefs.setString(_key, jsonString);
      }
    } catch (e) {
      print('❌ Erro ao atualizar no SharedPreferences: $e');
    }
  }

  // Deleta uma solicitação pelo índice
  static Future<void> deletarSolicitacao(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, String>> historico = await carregarHistorico();

      if (index >= 0 && index < historico.length) {
        historico.removeAt(index);
        String jsonString = jsonEncode(historico);
        await prefs.setString(_key, jsonString);
      }
    } catch (e) {
      print('❌ Erro ao deletar do SharedPreferences: $e');
    }
  }
}