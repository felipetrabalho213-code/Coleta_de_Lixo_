import 'package:flutter/material.dart';
import 'package:segue_coleta/views/special_collection/special_collection_success_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E9C4B), // Fundo verde da tela
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
                children: [
                  // Cabeçalho com botão voltar e Logo
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF1E9C4B),
                            child: const Text(
                              'S',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Segue Coleta',
                            style: TextStyle(
                              color: Color(0xFF1E9C4B),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // Para centralizar a logo
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Título da Tela
                  const Text(
                    'Solicitar Coleta Especial',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Grupo de Campos (Card Unificado)
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

                  // Área para Anexar Foto
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

                  const SizedBox(height: 30),

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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SpecialCollectionSuccessPage(),
                          ),
                        );// Ação ao enviar formulário
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para os campos de texto
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