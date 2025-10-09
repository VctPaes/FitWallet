import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/meal_service.dart';
import 'services/prefs_service.dart';
import 'pages/splash_page.dart';
import 'pages/home_page.dart';
import 'pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await PrefsService.init();

  runApp(
    ChangeNotifierProvider(
      create: (context) => MealService(),
      child: MealPrepLiteApp(prefs: prefs),
    ),
  );
}

class MealPrepLiteApp extends StatelessWidget {
  final PrefsService prefs;
  const MealPrepLiteApp({super.key, required this.prefs});

  static const green = Color(0xFF22C55E);
  static const cream = Color(0xFFFEF3C7);
  static const brown = Color(0xFF78350F);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: green,
      primary: green,
      secondary: brown,
      background: Colors.white,
      surface: Colors.white,
    );

    return MaterialApp(
      title: 'MealPrep Lite — Planejamento de refeições',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: brown,
          foregroundColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (ctx) => SplashPage(prefs: prefs),
        '/onboarding': (ctx) => OnboardingPage(prefs: prefs),
        '/home': (ctx) => HomePage(prefs: prefs),
      },
    );
  }
}