import 'package:bee_better_flutter/views/breathing/breathing_screen.dart';
import 'package:bee_better_flutter/views/auth/login.dart';
import 'package:bee_better_flutter/views/dashboard/dashboard_screen.dart';
import 'package:bee_better_flutter/views/home/AlarmsScreen.dart';
import 'package:bee_better_flutter/views/home/CalendarScreen.dart';
import 'package:bee_better_flutter/views/home/FeaturesScreen.dart';
import 'package:bee_better_flutter/views/home/ProfileProgressScreen.dart';
import 'package:bee_better_flutter/views/home/home_screen.dart';
import 'package:bee_better_flutter/views/notes/note_screen.dart';
import 'package:bee_better_flutter/views/onboarding/onboarding_flow.dart';
import 'package:bee_better_flutter/views/onboarding/registerScreen.dart';
import 'package:bee_better_flutter/views/settings/settings_screen.dart';
import 'package:bee_better_flutter/views/shop/ShopScreen.dart';
import 'package:bee_better_flutter/views/splash/splash_onboarding.dart';
import 'package:bee_better_flutter/views/splash/splash_pos_onboarding.dart';
import 'package:bee_better_flutter/views/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa notificações só em Android/iOS
  if (Platform.isAndroid || Platform.isIOS) {
    // inicialização das notificações aqui
  }

  await initializeDateFormatting('pt_BR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('pt', 'BR')],
      debugShowCheckedModeBanner: false,
      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/cadastro': (context) => const RegisterScreen(),
        '/pre_onboarding': (context) => const PreOnboardingScreen(),
        '/onboarding': (context) => const OnboardingFlow(),
        '/pos_onboarding': (context) => const SplashPosOnboarding(),
        '/home': (context) => const HomeScreen(),
        '/alarms': (context) => const AlarmsScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/featuresScreen': (context) => const FeaturesScreen(),
        '/menu': (context) => const ProfileProgressScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/notes': (context) => const NotesScreen(),
        '/breathing': (context) => const BreathingScreen(),
        '/shop': (context) => const ShopScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}