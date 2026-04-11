import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:flutter/material.dart';

// Cores do projeto
const Color beeBetterYellow = Color(0xFFFFD100);
const Color beeBetterOrange = Color(0xFFF7941D);
const Color beeBetterBrown = Color(0xFF3D2B1F);
const Color beeBetterGreyConfig = Color(0xFF4A4A4A);

class ProfileProgressScreen extends StatelessWidget {
  const ProfileProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    // Força a altura mínima a ser igual à altura da tela disponível
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        // Distribui os blocos para ocupar o espaço vertical total
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // BLOCO SUPERIOR: Perfil
                          _buildProfileCard(),

                          // BLOCO CENTRAL: Progresso
                          _buildProgressStrip(),

                          // BLOCO INFERIOR: Botões de Ação
                          Row(
                            children: [
                              _buildActionCardWrapper(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFF3C4), Color(0xFFFFE791)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'LOJA',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6B4219),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Image.network('https://i.imgur.com/Bj0U6yC.png', height: 60),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),
                              _buildActionCardWrapper(
                                backgroundColor: beeBetterGreyConfig,
                                child: Center(
                                  child: Image.network('https://i.imgur.com/74T2Hgf.png', height: 70),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/alarms');
          if (index == 1) Navigator.pushNamed(context, '/calendar');
          if (index == 4) Navigator.pushNamed(context, '/home');
          if (index == 3) Navigator.pushNamed(context, '/featuresScreen');
        },
      ),
    );
  }

  // --- MÉTODOS AUXILIARES ---

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: beeBetterYellow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4AF37), width: 3),
              image: const DecorationImage(
                image: NetworkImage('https://i.imgur.com/lwgH7H5.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _buildInfoField(Icons.person, 'Matheus Silva'),
                const SizedBox(height: 10),
                _buildInfoField(Icons.cake, '20 / 05 / 2002'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildProgressStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: beeBetterBrown,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EAC8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Novembro 2025',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: beeBetterBrown),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(Icons.chevron_left, color: Color(0xFFC0A68A), size: 20),
              _buildDayItem(isFlame: true),
              _buildDayItem(isFlame: true),
              _buildDayItem(isFlame: true),
              _buildDayItem(isCoin: true),
              _buildDayItem(isDot: true),
              _buildDayItem(isDot: true),
              _buildDayItem(isDot: true),
              const Icon(Icons.chevron_right, color: Color(0xFFC0A68A), size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem({bool isFlame = false, bool isCoin = false, bool isDot = false}) {
    Widget content;
    Color bgColor = const Color(0xFFFDF5E1);

    if (isFlame) {
      content = const Icon(Icons.local_fire_department, color: beeBetterOrange, size: 22);
    } else if (isCoin) {
      bgColor = const Color(0xFFFFE066);
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('+5', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: beeBetterBrown)),
          Icon(Icons.circle, color: beeBetterOrange, size: 14),
        ],
      );
    } else {
      content = const Icon(Icons.circle, color: Color(0xFFD4D4D4), size: 10);
    }

    return Container(
      width: 35,
      height: 45,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Center(child: content),
    );
  }

  Widget _buildActionCardWrapper({
    required Widget child,
    LinearGradient? gradient,
    Color? backgroundColor,
  }) {
    return Expanded(
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}