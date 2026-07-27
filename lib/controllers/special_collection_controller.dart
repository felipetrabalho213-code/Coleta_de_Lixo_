import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SpecialCollectionController {
  // Controllers dos campos de texto
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();

  // Lista em memória com o histórico
  List<Map<String, String>> historico = [];

  // Carrega o histórico salvo no SharedPreferences
  Future<void> carregarHistorico() async {
    historico = await StorageService.carregarHistorico();
  }

  // Valida e salva uma nova solicitação
  Future<bool> salvarSolicitacao() async {
    if (descricaoController.text.trim().isEmpty) {
      return false; // Falha na validação
    }

    await StorageService.salvarSolicitacao(
      descricao: descricaoController.text,
      endereco: enderecoController.text,
      nome: nomeController.text,
      telefone: telefoneController.text,
    );

    limparCampos();
    await carregarHistorico();
    return true; // Sucesso
  }

  // Apaga um item do histórico
  Future<void> deletarSolicitacao(int index) async {
    await StorageService.deletarSolicitacao(index);
    await carregarHistorico();
  }

  // Limpa os formulários
  void limparCampos() {
    descricaoController.clear();
    enderecoController.clear();
    nomeController.clear();
    telefoneController.clear();
  }

  // Libera a memória dos controllers ao fechar a tela
  void dispose() {
    descricaoController.dispose();
    enderecoController.dispose();
    nomeController.dispose();
    telefoneController.dispose();
  }
}