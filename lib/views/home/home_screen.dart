import 'package:bee_better_flutter/services/user_session.dart';
import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:bee_better_flutter/views/splash/flying_bee.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
  }

  void _navegarEAtualizar(String rota) async {
    await Navigator.pushNamed(context, rota);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int userLevel = UserSession.nivel > 0 ? UserSession.nivel : 1;
    int userCoins = UserSession.moedas;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFCDE7F7)),
          Image.asset(
            'assets/images/Fundo_nuvens.png',
            width: double.infinity,
            fit: BoxFit.cover,
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
            child: Image.asset('assets/images/colmeia.png', height: 120),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.60,
            minChildSize: 0.15,
            maxChildSize: 0.90,
            snap: true,
            snapSizes: const [0.15, 0.45, 0.90],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    // ALÇA
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // BOTÃO +
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding:
                        const EdgeInsets.only(right: 20, bottom: 10),
                        child: FloatingActionButton.small(
                          onPressed: () {},
                          backgroundColor: Colors.white,
                          elevation: 2,
                          child: const Icon(Icons.add, color: Colors.black),
                        ),
                      ),
                    ),

                    // TAREFAS
                    _buildTaskItem(
                      "Metas para hoje",
                      onTap: () => _navegarEAtualizar('/calendar'),
                    ),
                    _buildTaskItem(
                      "Metas em andamento",
                      onTap: () => _navegarEAtualizar('/calendar'),
                    ),
                    _buildTaskItem(
                      "Metas concluídas",
                      onTap: () => _navegarEAtualizar('/calendar'),
                    ),
                    _buildTaskItem(
                      "Missões",
                      onTap: () {}, // futuro
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) _navegarEAtualizar('/alarms');
          if (index == 1) _navegarEAtualizar('/calendar');
          if (index == 3) _navegarEAtualizar('/featuresScreen');
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
          Text(
            coins.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.circle, color: Color(0xFFFFD100), size: 18),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String title, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.chevron_right, color: Colors.black),
          ],
        ),
      ),
    );
  }
}