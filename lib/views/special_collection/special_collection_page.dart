import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import 'special_collection_success_page.dart';

class SpecialCollectionPage extends StatefulWidget {
  const SpecialCollectionPage({super.key});

  @override
  State<SpecialCollectionPage> createState() => _SpecialCollectionPageState();
}

class _SpecialCollectionPageState extends State<SpecialCollectionPage> {
  // Controllers dos campos
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();

  List<Map<String, String>> _historico = [];

  @override
  void initState() {
    super.initState();
    _atualizarHistorico();
  }

  Future<void> _atualizarHistorico() async {
    final dados = await StorageService.carregarHistorico();
    setState(() {
      _historico = dados;
    });
  }

  // Exibe o Modal com Detalhes e Opção de Excluir
  void _mostrarDetalhesESolucao(Map<String, String> item, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detalhes da Solicitação',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                    onPressed: () async {
                      // Deleta o item
                      await StorageService.deletarSolicitacao(index);
                      await _atualizarHistorico();
                      
                      if (context.mounted) {
                        Navigator.pop(context); // Fecha o modal
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Solicitação excluída com sucesso!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildDetalheItem('Descrição:', item['descricao']),
              _buildDetalheItem('Endereço:', item['endereco']),
              _buildDetalheItem('Solicitante:', item['nome']),
              _buildDetalheItem('Telefone:', item['telefone']),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E9C4B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetalheItem(String titulo, String? valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            (valor == null || valor.isEmpty) ? 'Não informado' : valor,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _enderecoController.dispose();
    _nomeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E9C4B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Image.asset(
                        'assets/images/teste.png',
                        height: 40,
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Título da Tela
                  const Center(
                    child: Text(
                      'Solicitar Coleta Especial',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Campos de Texto
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildInputField(
                          controller: _descricaoController,
                          hint: 'Descreva o que precisa retirar',
                          icon: Icons.keyboard_arrow_down,
                        ),
                        const Divider(height: 1),
                        _buildInputField(
                          controller: _enderecoController,
                          hint: 'Endereço para coleta',
                        ),
                        const Divider(height: 1),
                        _buildInputField(
                          controller: _nomeController,
                          hint: 'Nome do solicitante',
                        ),
                        const Divider(height: 1),
                        _buildInputField(
                          controller: _telefoneController,
                          hint: 'Telefone para contato',
                          icon: Icons.keyboard_arrow_down,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Anexar Foto
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Color(0xFF1E9C4B),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Anexar foto (opcional)',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botão Enviar Solicitação
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E9C4B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        if (_descricaoController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Preencha a descrição da coleta.'),
                            ),
                          );
                          return;
                        }

                        // 1. Salva no banco de dados local
                        await StorageService.salvarSolicitacao(
                          descricao: _descricaoController.text,
                          endereco: _enderecoController.text,
                          nome: _nomeController.text,
                          telefone: _telefoneController.text,
                        );

                        // 2. Atualiza a lista na tela
                        await _atualizarHistorico();

                        // Limpa os campos após salvar
                        _descricaoController.clear();
                        _enderecoController.clear();
                        _nomeController.clear();
                        _telefoneController.clear();

                        // 3. Navega para a tela de sucesso
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SpecialCollectionSuccessPage(),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'ENVIAR SOLICITAÇÃO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- HISTÓRICO COM INTERATIVIDADE ---
                  const Text(
                    'Histórico de Solicitações',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _historico.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'Nenhuma solicitação enviada ainda.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _historico.length,
                          itemBuilder: (context, index) {
                            final item = _historico[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                onTap: () => _mostrarDetalhesESolucao(item, index),
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFF1E9C4B),
                                  child: Icon(Icons.assignment_turned_in,
                                      color: Colors.white, size: 20),
                                ),
                                title: Text(
                                  item['descricao'] ?? 'Sem Título',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  item['endereco'] != null &&
                                          item['endereco']!.isNotEmpty
                                      ? item['endereco']!
                                      : 'Sem endereço cadastrado',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () async {
                                    await StorageService.deletarSolicitacao(index);
                                    await _atualizarHistorico();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Solicitação excluída!'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          border: InputBorder.none,
          suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        ),
      ),
    );
  }
}