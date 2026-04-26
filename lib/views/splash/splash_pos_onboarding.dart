import 'dart:async';

import 'package:bee_better_flutter/services/user_session.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class SplashPosOnboarding extends StatefulWidget {
  const SplashPosOnboarding({super.key});

  @override
  State<SplashPosOnboarding> createState() => _SplashPosOnboardingState();
}

class _SplashPosOnboardingState extends State<SplashPosOnboarding>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  Future? _onboardingFuture;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_onboardingFuture == null) {
      _onboardingFuture = ModalRoute.of(context)?.settings.arguments as Future?;
      _waitAndNavigate();
    }
  }

  Future<void> _waitAndNavigate() async {
    try {
      await Future.wait([
        Future.delayed(const Duration(seconds: 4)),
        if (_onboardingFuture != null) _onboardingFuture!,
      ]);

      // Busca os dados atualizados antes de ir para a home
      await _refreshUserSession();

      if (mounted) Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar dados. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  Future<void> _refreshUserSession() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/users/${UserSession.id}'),
      headers: {
        'Authorization': 'Bearer ${UserSession.token}',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      UserSession.dataNascimento = json['birth_date'] ?? '';
      //ADICIONAR CAMPOS FALTANTES
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
      backgroundColor: const Color(0xFFF9F6D5),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  'assets/images/abelha_login.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              RotationTransition(
                turns: _controller,
                child: Image.asset(
                  'assets/images/anel_carregando.png',
                  height: 45,
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