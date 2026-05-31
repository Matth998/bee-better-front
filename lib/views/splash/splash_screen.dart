import 'package:bee_better_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animação de pulso
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Após 2 segundos verifica se já tem sessão salva
    Timer(const Duration(seconds: 2), () => _verificarSessao());
  }

  Future<void> _verificarSessao() async {
    if (!mounted) return;

    try {
      final temSessao = await AuthService.restaurarSessao();

      if (!mounted) return;

      if (temSessao) {
        // Já está logado — vai direto para home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Não tem sessão — vai para login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // Em caso de erro, vai para login
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1B8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Image.asset(
                'assets/images/abelha_login.png',
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
                fontFamily: 'Roboto',
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