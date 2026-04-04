import 'package:bee_better_flutter/views/auth/login.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // 1. Configura a animação de pulso
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000), // 1 segundo por ciclo (vai e volta)
      vsync: this,
    )..repeat(reverse: true); // Faz o efeito de "vai e vem"

    _animation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 2. Timer para navegar após 2 segundos -- 10 segundo para teste iniciais
    Timer(const Duration(seconds: 10), () {
      // Navegar para a nossa tela principal (Login)
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1B8), // Cor de fundo amarela clara
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Efeito de pulso na imagem
            ScaleTransition(
              scale: _animation,
              child: Image.network(
                'https://i.imgur.com/MvWOIjb.png',
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'BEE BETTER',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto', // Verificar fonte correta com a Julia
                letterSpacing: 2.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

