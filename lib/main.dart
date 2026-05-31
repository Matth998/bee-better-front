import 'package:bee_better_flutter/services/AlarmNotificationService.dart';
import 'package:bee_better_flutter/views/breathing/breathing_screen.dart';
import 'package:bee_better_flutter/views/auth/login.dart';
import 'package:bee_better_flutter/views/cloakroom/cloakroom_screen.dart';
import 'package:bee_better_flutter/views/dashboard/dashboard_screen.dart';
import 'package:bee_better_flutter/views/home/alarms_screen.dart';
import 'package:bee_better_flutter/views/home/calendar_screen.dart';
import 'package:bee_better_flutter/views/home/features_screen.dart';
import 'package:bee_better_flutter/views/home/profile_progress_screen.dart';
import 'package:bee_better_flutter/views/home/home_screen.dart';
import 'package:bee_better_flutter/views/notes/note_screen.dart';
import 'package:bee_better_flutter/views/onboarding/onboarding_flow.dart';
import 'package:bee_better_flutter/views/onboarding/registerScreen.dart';
import 'package:bee_better_flutter/views/pomodoro/pomodoro_screen.dart';
import 'package:bee_better_flutter/views/pomodoro/pomodoro_settings_screen.dart';
import 'package:bee_better_flutter/views/settings/settings_screen.dart';
import 'package:bee_better_flutter/views/shop/shop_screen.dart';
import 'package:bee_better_flutter/views/splash/splash_onboarding.dart';
import 'package:bee_better_flutter/views/splash/splash_pos_onboarding.dart';
import 'package:bee_better_flutter/views/splash/splash_screen.dart';
import 'package:bee_better_flutter/views/goals/goals_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa notificações só em Android/iOS
  if (Platform.isAndroid || Platform.isIOS) {
    await AlarmNotificationService.initialize();
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
        '/goals/today': (context) => const GoalsScreen(type: GoalScreenType.today),
        '/goals/in-progress': (context) => const GoalsScreen(type: GoalScreenType.inProgress),
        '/goals/completed': (context) => const GoalsScreen(type: GoalScreenType.completed),
        '/goals/missions': (context) => const GoalsScreen(type: GoalScreenType.missions),
        '/pomodoro': (context) => const PomodoroScreen(),
        '/pomodoroSettings': (context) => const PomodoroSettingsScreen(),
        '/cloakroom': (context) => const CloakroomScreen(),
      },
    );
  }
}