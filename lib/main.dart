import 'package:flutter/material.dart';
import 'services/prefs_service.dart';
import 'pages/splash_page.dart';
import 'pages/home_page.dart';
import 'pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await PrefsService.init();

  runApp(FitWalletApp(prefs: prefs));
}

class FitWalletApp extends StatelessWidget {
  final PrefsService prefs;
  const FitWalletApp({super.key, required this.prefs});

  static const emerald = Color(0xFF059669);
  static const navy = Color(0xFF0B1220);
  static const gray = Color(0xFF475569);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: emerald,
      primary: emerald,
      secondary: gray,
      background: Colors.white,
      surface: Colors.white,
    );

    return MaterialApp(
      title: 'FitWallet — finanças rápidas',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
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
