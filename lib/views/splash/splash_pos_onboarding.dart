import 'dart:async';

import 'package:flutter/material.dart';

class SplashPosOnboarding extends StatefulWidget {
  const SplashPosOnboarding({super.key});

  @override
  State<SplashPosOnboarding> createState() => _SplashPosOnboardingState();
}

class _SplashPosOnboardingState extends State<SplashPosOnboarding>
    with SingleTickerProviderStateMixin { // Necessário para a animação

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Configura o tempo de uma volta completa
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // Faz a animação repetir infinitamente

    // LOGICA DE TRANSIÇÃO:
    Timer(const Duration(seconds: 4), () {
      if (mounted) { // Verifica se o usuário não saiu da tela antes do tempo
        Navigator.pushReplacementNamed(context, '/home');
      }
    });

  }



  @override
  void dispose() {
    _controller.dispose(); // Importante para não gastar memória
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6D5),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo da Abelha (Estático)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.network(
                  'https://i.imgur.com/lwgH7H5.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              // O Anel de Carregamento (Animado)
              RotationTransition(
                turns: _controller, // O controller faz ele girar
                child: Image.network(
                  'https://i.imgur.com/dIbDBnq.png',
                  height: 45, // Ajuste leve no tamanho para destaque
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Obrigado! estamos prontos para oferecer um aplicativo pensado em você!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}