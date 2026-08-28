import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SpecialCollectionController {
  // Controllers dos campos de texto
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();

  // Armazena a imagem selecionada em formato Base64
  String? imagemBase64;

  // Lista do histórico na memória
  List<Map<String, String>> historico = [];

  // Carrega o histórico
  Future<void> carregarHistorico() async {
    historico = await StorageService.carregarHistorico();
  }

  // Salva uma nova solicitação
  Future<bool> salvarSolicitacao() async {
    if (descricaoController.text.trim().isEmpty) {
      return false;
    }

    await StorageService.salvarSolicitacao(
      descricao: descricaoController.text,
      endereco: enderecoController.text,
      nome: nomeController.text,
      telefone: telefoneController.text,
      imagemBase64: imagemBase64,
    );

    limparCampos();
    await carregarHistorico();
    return true;
  }

  // Atualiza um registro do histórico
  Future<void> atualizarSolicitacao(int index, Map<String, String> dadosAtualizados) async {
    await StorageService.atualizarSolicitacao(index, dadosAtualizados);
    await carregarHistorico();
  }

  // Apaga um item do histórico
  Future<void> deletarSolicitacao(int index) async {
    await StorageService.deletarSolicitacao(index);
    await carregarHistorico();
  }

  // Limpa os campos
  void limparCampos() {
    descricaoController.clear();
    enderecoController.clear();
    nomeController.clear();
    telefoneController.clear();
    imagemBase64 = null;
  }

  // Libera a memória
  void dispose() {
    descricaoController.dispose();
    enderecoController.dispose();
    nomeController.dispose();
    telefoneController.dispose();
  }
}