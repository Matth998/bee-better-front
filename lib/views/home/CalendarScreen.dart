import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now(); // Controla o círculo no dia atual

  // Simulação de tarefas por dia
  final List<String> tasks = [
    "Comprar o bolo",
    "Limpar a casa",
    "Tirar o lixo",
    "Lavar o cabelo",
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 1. FUNDO COLMEIA
          Positioned.fill(
            child: Image.network(
              'https://i.imgur.com/c9STTP1.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. CONTEÚDO
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // CARD DO CALENDÁRIO
                  _buildCalendarCard(screenHeight),

                  const SizedBox(height: 20),

                  // BOTÃO ADICIONAR (+)
                  Align(
                    alignment: Alignment.centerRight,
                    child: FloatingActionButton.small(
                      onPressed: () {},
                      backgroundColor: Colors.white,
                      elevation: 4,
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // LISTA DE TAREFAS DO DIA
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildTaskTile(tasks[index], screenHeight),
                  ),

                  const SizedBox(height: 100), // Espaço para o menu
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1, // 1 é o ícone do Calendário
        onTap: (index) {
          if (index == 4) Navigator.pushNamed(context, '/home');
          if (index == 0) Navigator.pushNamed(context, '/alarms');
          if (index == 3) Navigator.pushNamed(context, '/featuresScreen');
          if (index == 5) Navigator.pushNamed(context, '/menu');
        },
      ),
    );
  }

  // Widget do Card de Calendário
  Widget _buildCalendarCard(double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          // TOPO MARROM (Novembro)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: const BoxDecoration(
              color: Color(0xFF3D2B1F), // Marrom escuro do design
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.arrow_left, color: Color(0xFFF7941D)),
                Text(
                  "Novembro",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Icon(Icons.arrow_right, color: Color(0xFFF7941D)),
              ],
            ),
          ),
          // CORPO DO CALENDÁRIO
          Padding(
            padding: const EdgeInsets.all(10),
            child: Image.network(
              'https://i.imgur.com/g5prqZ2.png', // Necessário colocar calendario real
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // Itens da lista de tarefas com o círculo de check à esquerda
  Widget _buildTaskTile(String title, double screenHeight) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: screenHeight * 0.018),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Row(
        children: [
          // CÍRCULO DE STATUS
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFA2D033), width: 2),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}