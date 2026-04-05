import 'package:flutter/material.dart';
import 'dart:math';

class FlyingBee extends StatelessWidget {
  const FlyingBee({super.key});

  @override
  Widget build(BuildContext context) {
    // Usando o Random para não manter as abelhas no mesmo local
    final random = Random();

    return Positioned(
      top: random.nextDouble() * 150 + 20, // Posição aleatória na altura das nuvens
      left: random.nextDouble() * MediaQuery.of(context).size.width - 30,
      child: Image.network(
        'https://i.imgur.com/mDAiv6K.png', // A abelhinha pequena
        height: 25,
      ),
    );
  }
}