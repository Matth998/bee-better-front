import 'package:bee_better_flutter/views/auth/login.dart';
import 'package:bee_better_flutter/views/onboarding/onboarding_flow.dart';
import 'package:bee_better_flutter/views/onboarding/registerScreen.dart';
import 'package:bee_better_flutter/views/splash/splash_onboarding.dart';
import 'package:bee_better_flutter/views/splash/splash_pos_onboarding.dart';
import 'package:bee_better_flutter/views/splash/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/cadastro': (context) => const RegisterScreen(),
        '/pre_onboarding': (context) => const PreOnboardingScreen(),
        '/onboarding': (context) => const OnboardingFlow(),
        '/pos_onboarding': (context) => const SplashPosOnboarding()
      },
    );
  }
}