import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFF7941D),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.access_time, 0),
              _buildNavItem(Icons.calendar_month, 1),
              const SizedBox(width: 40), // Espaço para o botão Home
              _buildNavItem(Icons.menu, 3),
              _buildNavItem(Icons.person_outline, 5),
            ],
          ),

          // BOTÃO HOME CENTRALIZADO E SALTADO
          Positioned(
            top: -25,
            child: GestureDetector(
              onTap: () => onTap(4),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7941D),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFFFD100),
                  radius: 28,
                  child: Icon(
                      Icons.home,
                      color: currentIndex == 4 ? Colors.black : Colors.black54,
                      size: 35
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = currentIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        size: 30,
        color: isSelected ? Colors.black : Colors.black.withOpacity(0.5),
      ),
      onPressed: () => onTap(index),
    );
  }
}