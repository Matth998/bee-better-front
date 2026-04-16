import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:flutter/material.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  final List<String> alarms = [
    "05 : 30",
    "06 : 00",
    "12 : 00",
    "13 : 00",
    "18 : 00",
  ];

  @override
  Widget build(BuildContext context) {
    // Calculando tamanho proporcional da tela
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      body: Stack(
        children: [
          // 1. FUNDO DA COLMEIA
          Positioned.fill(
            child: Image.network(
              'https://i.imgur.com/c9STTP1.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. CONTEÚDO COM ROLAGEM
          SafeArea(
            child: SingleChildScrollView(
              // Padding responsivo lateral
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: 20
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: FloatingActionButton.small(
                        onPressed: () {},
                        backgroundColor: Colors.white,
                        elevation: 4,
                        child: const Icon(
                            Icons.add, color: Colors.black, size: 24),
                      ),
                    ),
                  ),

                  // LISTA DE ALARMES
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: alarms.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildAlarmItem(alarms[index], screenHeight),
                  ),

                  SizedBox(height: screenHeight * 0.03), // Espaço proporcional

                  // 3. CARD DE MEL RESPONSIVO
                  Container(
                    // Altura baseada em 20% da altura da tela
                    height: screenHeight * 0.20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      image: const DecorationImage(
                        image: NetworkImage('https://i.imgur.com/gpU56RP.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.watch_later_outlined,
                        // Ícone também escala com a tela
                        size: screenHeight * 0.08,
                        color: const Color(0xFF63450E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Espaço para a BottomNav
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0, // 0 representa o alarme
        onTap: (index) {
          if (index == 4) Navigator.pushNamed(context, '/home');
          if (index == 1) Navigator.pushNamed(context, '/calendar');
          if (index == 3) Navigator.pushNamed(context, '/featuresScreen');
          if (index == 5) Navigator.pushNamed(context, '/menu');
        },
      ),
    );
  }

  // --- PARÂMETRO DE ALTURA ---
  Widget _buildAlarmItem(String time, double screenHeight) {
    return Container(
      // Altura do card proporcional à tela
      padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: screenHeight * 0.015
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: TextStyle(
              // Fonte levemente menor para caber melhor em telas estreitas
              fontSize: screenHeight * 0.035,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Icon(
            Icons.access_time_filled,
            color: Colors.black,
            size: screenHeight * 0.025,
          ),
        ],
      ),
    );
  }
}