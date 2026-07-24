import 'package:flutter/material.dart';

import '../calendar/calendar_page.dart';
import '../map/map_page.dart';
import '../notification/notification_page.dart';
import '../special_collection/special_collection_page.dart';
import '../truck/truck_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Logo
              Center(
                child: Image.asset(
                  'assets/images/teste.png',
                  height: 90,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        buildCard(
                          context: context,
                          icon: Icons.arrow_downward,
                          title: 'Ver\nCaminhão',
                          color: const Color(0xFF006B4F),
                          // ✅ Correto: abre a página com o mapa real
                          page: const TruckPage(),
                        ),
                        buildCard(
                          context: context,
                          icon: Icons.notifications_none,
                          title: 'Receber\nAviso',
                          color: const Color(0xFF006B4F),
                          page: const NotificationPage(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        buildCard(
                          context: context,
                          icon: Icons.calendar_today,
                          title: 'Calendário',
                          color: const Color(0xFF006B4F),
                          page: const CalendarPage(),
                        ),
                        buildCard(
                          context: context,
                          icon: Icons.menu_book,
                          title: 'Coleta\nEspecial',
                          color: const Color(0xFF006B4F),
                          page: const SpecialCollectionPage(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required Widget page,
  }) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(icon, color: color, size: 26),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}