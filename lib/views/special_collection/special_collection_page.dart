import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/special_collection_controller.dart';

class SpecialCollectionPage extends StatefulWidget {
  const SpecialCollectionPage({super.key});

  @override
  State<SpecialCollectionPage> createState() => _SpecialCollectionPageState();
}

class _SpecialCollectionPageState extends State<SpecialCollectionPage> {
  final SpecialCollectionController _controller = SpecialCollectionController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _controller.carregarHistorico().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = File(pickedFile.path);
        _controller.imagemBase64 = base64Encode(bytes);
      });
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF1E9C49)),
              title: const Text('Tirar Foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF1E9C49)),
              title: const Text('Escolher da Galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enviarSolicitacao() async {
    bool sucesso = await _controller.salvarSolicitacao();

    if (sucesso && mounted) {
      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação registrada com sucesso!'),
          backgroundColor: Color(0xFF1E9C49),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha pelo menos a descrição da solicitação.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Modal corrigido para visualização, edição e exclusão
  void _exibirDetalhesSolicitacao(int index, Map<String, String> item) {
    final descEditController = TextEditingController(text: item['descricao']);
    final endEditController = TextEditingController(text: item['endereco']);
    final nomeEditController = TextEditingController(text: item['nome']);
    final telEditController = TextEditingController(text: item['telefone']);
    String? imagemBase64Edit = item['imagem'];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.85,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Detalhes da Solicitação',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                if (imagemBase64Edit != null && imagemBase64Edit.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      base64Decode(imagemBase64Edit),
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                  ),
                  
                const SizedBox(height: 16),
                
                TextField(
                  controller: descEditController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                
                TextField(
                  controller: endEditController,
                  decoration: const InputDecoration(
                    labelText: 'Endereço',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                
                TextField(
                  controller: nomeEditController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                
                TextField(
                  controller: telEditController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _controller.deletarSolicitacao(index);
                        setState(() {});
                      },
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E9C49),
                          ),
                          onPressed: () async {
                            Map<String, String> dadosAtualizados = {
                              'id': item['id'] ?? '',
                              'descricao': descEditController.text,
                              'endereco': endEditController.text,
                              'nome': nomeEditController.text,
                              'telefone': telEditController.text,
                              'data': item['data'] ?? '',
                              'imagem': imagemBase64Edit ?? '',
                            };

                            await _controller.atualizarSolicitacao(index, dadosAtualizados);
                            if (context.mounted) Navigator.pop(context);
                            setState(() {});
                          },
                          child: const Text('Salvar', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E9C49),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 32,
                          errorBuilder: (context, error, stackTrace) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.recycling, color: Colors.green.shade600, size: 28),
                              const SizedBox(width: 6),
                              const Text('Segue Coleta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    children: [
                      const Text(
                        'Solicitar Coleta Especial',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Card agrupado com os inputs do formulário
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _controller.descricaoController,
                              decoration: const InputDecoration(
                                hintText: 'Descreva o que precisa retirar',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                border: InputBorder.none,
                                suffixIcon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                              ),
                            ),
                            Divider(height: 1, color: Colors.grey.shade300),
                            TextField(
                              controller: _controller.enderecoController,
                              decoration: const InputDecoration(
                                hintText: 'Endereço para coleta',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                border: InputBorder.none,
                              ),
                            ),
                            Divider(height: 1, color: Colors.grey.shade300),
                            TextField(
                              controller: _controller.nomeController,
                              decoration: const InputDecoration(
                                hintText: 'Nome do solicitante',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                border: InputBorder.none,
                              ),
                            ),
                            Divider(height: 1, color: Colors.grey.shade300),
                            TextField(
                              controller: _controller.telefoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'Telefone para contato',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                border: InputBorder.none,
                                suffixIcon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Botão de Câmera
                      GestureDetector(
                        onTap: _showImagePickerModal,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(_selectedImage!, height: 80, width: 80, fit: BoxFit.cover),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Color(0xFF1E9C49), size: 28),
                                    ),
                              const SizedBox(height: 12),
                              Text(
                                _selectedImage != null ? 'Foto anexada (Toque para trocar)' : 'Anexar foto (opcional)',
                                style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botão Enviar
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _enviarSolicitacao,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E9C49),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                            elevation: 0,
                          ),
                          child: const Text('ENVIAR SOLICITAÇÃO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Histórico Clicável
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Histórico de Solicitações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                          const SizedBox(height: 16),

                          _controller.historico.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Text('Nenhuma solicitação enviada ainda.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _controller.historico.length,
                                  itemBuilder: (context, index) {
                                    final item = _controller.historico[index];
                                    final String? imagemBase64 = item['imagem'];

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ListTile(
                                        onTap: () => _exibirDetalhesSolicitacao(index, item),
                                        leading: (imagemBase64 != null && imagemBase64.isNotEmpty)
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.memory(base64Decode(imagemBase64), width: 44, height: 44, fit: BoxFit.cover),
                                              )
                                            : Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
                                              ),
                                        title: Text(item['descricao'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        subtitle: Text(
                                          '${item['endereco'] ?? ''}\n${item['nome'] ?? ''}',
                                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () async {
                                            await _controller.deletarSolicitacao(index);
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}