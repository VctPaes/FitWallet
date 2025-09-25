import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluxo Inicial',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF862EC1), // Roxo personalizado
          brightness: Brightness.light,
        ),
        primaryColor: Color(0xFF862EC1), // Garante o roxo como cor primária
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => SplashPage(),
        '/onboarding': (_) => OnboardingPage(),
        '/home': (_) => HomePage(),
      },
    );
  }
}
