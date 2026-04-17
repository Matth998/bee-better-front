import 'package:bee_better_flutter/services/user_session.dart';
import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:bee_better_flutter/views/splash/flying_bee.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int userLevel = 1;
    int userCoins = UserSession.moedas;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFCDE7F7)),
          Image.network(
              'https://i.imgur.com/XcgcFuj.png',
              width: double.infinity,
              fit: BoxFit.cover
          ),

          ...List.generate(userLevel, (index) => const FlyingBee()),

          Positioned(
            top: 45,
            right: 20,
            child: _buildCoinCounter(userCoins),
          ),

          Positioned(
            top: 40,
            left: 20,
            child: Image.network('https://i.imgur.com/Bj0U6yC.png', height: 120),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: _buildTaskList(),
            ),
          ),
        ],
      ),
      // CHAMADA DO MENU FIXO
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 4, // 4 representa a Home
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/alarms');
          if (index == 1) Navigator.pushNamed(context, '/calendar');
          if (index == 3) Navigator.pushNamed(context, '/featuresScreen');
          if (index == 5) Navigator.pushNamed(context, '/menu');
        },
      ),
    );
  }

  Widget _buildCoinCounter(int coins) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5A2B),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(coins.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          const Icon(Icons.circle, color: Color(0xFFFFD100), size: 18),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: FloatingActionButton.small(
              onPressed: () {},
              backgroundColor: Colors.white,
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
        ),
        _buildTaskItem("Tarefas para hoje"),
        _buildTaskItem("Tarefas em andamento"),
        _buildTaskItem("Tarefas em concluídas"),
      ],
    );
  }

  Widget _buildTaskItem(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Icon(Icons.chevron_right, color: Colors.black),
        ],
      ),
    );
  }
}