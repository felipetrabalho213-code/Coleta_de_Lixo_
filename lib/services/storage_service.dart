import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Enumeração para tipar os perfis do sistema
enum TipoUsuario { usuario, motorista, adm }

class StorageService {
  // Chaves do SharedPreferences
  static const String _keyColetas = 'historico_coletas';
  static const String _keyUsuarios = 'usuarios_cadastrados';
  static const String _keyUsuarioLogado = 'usuario_logado';

  // ==========================================
  //  SEÇÃO 1: GESTÃO DE USUÁRIOS E AUTENTICAÇÃO
  // ==========================================

  /// Cadastra um novo usuário, motorista ou administrador
  static Future<bool> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required TipoUsuario tipo,
    String? telefone,
    String? cnh, // Opcional, útil para motorista
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, String>> usuarios = await carregarUsuarios();

      // Verifica se o e-mail já foi cadastrado
      bool jaExiste = usuarios.any((u) => u['email'] == email);
      if (jaExiste) {
        print('❌ E-mail já cadastrado!');
        return false;
      }

      Map<String, String> novoUsuario = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'nome': nome,
        'email': email,
        'senha': senha,
        'tipo': tipo.name, // 'usuario', 'motorista' ou 'adm'
        'telefone': telefone ?? '',
        'cnh': cnh ?? '',
        'dataCriacao': DateTime.now().toString(),
      };

      usuarios.add(novoUsuario);

      String jsonString = jsonEncode(usuarios);
      await prefs.setString(_keyUsuarios, jsonString);
      return true;
    } catch (e) {
      print('❌ Erro ao cadastrar usuário: $e');
      return false;
    }
  }

  /// Retorna a lista de todos os usuários cadastrados
  static Future<List<Map<String, String>>> carregarUsuarios() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_keyUsuarios);

      if (jsonString != null && jsonString.isNotEmpty) {
        List<dynamic> listJson = jsonDecode(jsonString);
        return listJson.map((item) => Map<String, String>.from(item)).toList();
      }
    } catch (e) {
      print('❌ Erro ao carregar usuários: $e');
    }
    return [];
  }

  /// Realiza o login comparando e-mail e senha e salva a sessão ativa
  static Future<Map<String, String>?> realizarLogin({
    required String email,
    required String senha,
  }) async {
    try {
      List<Map<String, String>> usuarios = await carregarUsuarios();

      for (var user in usuarios) {
        if (user['email'] == email && user['senha'] == senha) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_keyUsuarioLogado, jsonEncode(user));
          return user;
        }
      }
    } catch (e) {
      print('❌ Erro ao realizar login: $e');
    }
    return null; // Usuário ou senha inválidos
  }

  /// Retorna os dados do usuário atualmente logado (Sessão ativa)
  static Future<Map<String, String>?> obterUsuarioLogado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_keyUsuarioLogado);

      if (jsonString != null && jsonString.isNotEmpty) {
        return Map<String, String>.from(jsonDecode(jsonString));
      }
    } catch (e) {
      print('❌ Erro ao obter usuário logado: $e');
    }
    return null;
  }

  /// Encerra a sessão do usuário ativo
  static Future<void> deslogar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUsuarioLogado);
    } catch (e) {
      print('❌ Erro ao deslogar: $e');
    }
  }

  // ==========================================
  //  SEÇÃO 2: HISTÓRICO DE COLETAS (SEU CÓDIGO)
  // ==========================================

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
      await prefs.setString(_keyColetas, jsonString);
    } catch (e) {
      print('❌ Erro ao salvar no SharedPreferences: $e');
    }
  }

  // Carrega a lista completa
  static Future<List<Map<String, String>>> carregarHistorico() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_keyColetas);

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
        await prefs.setString(_keyColetas, jsonString);
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
        await prefs.setString(_keyColetas, jsonString);
      }
    } catch (e) {
      print('❌ Erro ao deletar do SharedPreferences: $e');
    }
  }
}