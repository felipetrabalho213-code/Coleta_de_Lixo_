import 'package:flutter/material.dart';

class TruckPage extends StatelessWidget {
  const TruckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // Fundo (Mapa)
          Positioned.fill(
            child: Image.asset(
              'assets/images/map.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  // Linha superior
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      CircleAvatar(
                        radius: 23,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.black,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),

                      Image.asset(
                        'assets/images/logo.png',
                        height: 55,
                      ),

                      CircleAvatar(
                        radius: 23,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none),
                          color: Colors.black,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Barra de pesquisa
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Pesquisar bairro...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}