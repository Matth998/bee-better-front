import 'package:flutter/material.dart';
import 'dart:async';

class PreOnboardingScreen extends StatefulWidget {
  const PreOnboardingScreen({super.key});

  @override
  State<PreOnboardingScreen> createState() => _PreOnboardingScreenState();
}

class _PreOnboardingScreenState extends State<PreOnboardingScreen> {

  @override
  void initState() {
    super.initState();

    // Timer de 3 segundos para o usuário conseguir ler o texto
    Timer(const Duration(seconds: 3), () {
      // Aqui mandará para a primeira das 9 telas de perguntas (Necessário Back-end finalizado)
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1B8),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagem da abelha
            Center(
              child: Image.network(
                'https://i.imgur.com/zbBifE3.png',
                height: 120,
              ),
            ),

            const SizedBox(height: 40),

            // Título principal
            const Text(
              'Queremos te conhecer um pouco melhor!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            // Subtítulo / Descrição
            const Text(
              'Estamos curiosos sobre como podemos nos adaptar a você e te ajudar na sua rotina',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}