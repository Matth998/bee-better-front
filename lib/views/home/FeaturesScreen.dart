import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:flutter/material.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

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
                  // Garante que o conteúdo tenha no mínimo a altura da tela
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 40,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMenuCard(
                            title: 'Dashboard',
                            iconPath: 'https://i.imgur.com/JkgOJSC.png',
                            backgroundUrl: 'https://i.imgur.com/8MxywnU.png',
                            onTap: () =>
                                Navigator.pushNamed(context, '/dashboard'),
                          ),
                          _buildMenuCard(
                            title: 'Anotações',
                            iconPath: 'https://i.imgur.com/Pe0gbo1.png',
                            backgroundUrl: 'https://i.imgur.com/CAp6y1l.png',
                            onTap: () => Navigator.pushNamed(context, '/notes'),
                          ),
                          _buildMenuCard(
                            title: 'Respiração',
                            iconPath: 'https://i.imgur.com/qWQd5Uz.png',
                            backgroundUrl: 'https://i.imgur.com/mzDOMAE.png',
                            onTap: () =>
                                Navigator.pushNamed(context, '/breathing'),
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
        currentIndex: 3,
        onTap: (index) {
          if (index == 4) Navigator.pushNamed(context, '/home');
          if (index == 0) Navigator.pushNamed(context, '/alarms');
          if (index == 1) Navigator.pushNamed(context, '/calendar');
          if (index == 5) Navigator.pushNamed(context, '/menu');
        },
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String iconPath,
    required String backgroundUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  backgroundUrl,
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.8),
                ),
              ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(iconPath, width: 60, height: 60),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
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
}
