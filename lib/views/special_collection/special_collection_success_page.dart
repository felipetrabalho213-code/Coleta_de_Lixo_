import 'package:flutter/material.dart';
import 'special_collection_success_page.dart';
class SpecialCollectionSuccessPage extends StatelessWidget {
  const SpecialCollectionSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF1E9C4B),
              child: const Text(
                'S',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Segue Coleta',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Topo Verde Arredondado com Ícone de Check Sobreposto
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Bloco Verde
                  Container(
                    height: 130,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E9C4B),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),

                  // Círculo com o Check
                  Positioned(
                    top: 80,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E9C4B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Título de Sucesso
            const Text(
              'Solicitação\nEnviada!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E9C4B),
                height: 1.1,
              ),
            ),

            const SizedBox(height: 24),

            // Texto Explicativo
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Sua solicitação de coleta especial foi registrada com sucesso. Em breve, entraremos em contato para confirmar os detalhes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ),

            const Spacer(),

            // Botão Voltar ao Início
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
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
                    // Volta direto para a tela inicial (removendo as pilhas anteriores)
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text(
                    'VOLTAR AO INÍCIO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}