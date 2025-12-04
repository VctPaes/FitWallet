import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/prefs_service.dart';

class SplashPage extends StatefulWidget {
  final PrefsService prefs;
  const SplashPage({super.key, required this.prefs});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Aguarda um tempo mínimo para exibir a logo e depois decide
    Timer(const Duration(milliseconds: 1500), _decideNext);
  }

  Future<void> _decideNext() async {
    // 1. Verifica se o onboarding foi concluído
    final onboardingCompleted = widget.prefs.getOnboardingCompleted();
    
    if (!onboardingCompleted) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
      return;
    }

    // 2. Verifica se existe sessão válida no Supabase
    final session = Supabase.instance.client.auth.currentSession;

    if (mounted) {
      if (session != null) {
        // Usuário já logado -> Direto para Home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Não logado -> Tela de Autenticação
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/splash.png', width: 120, height: 120),
            const SizedBox(height: 24),
            const Text(
              'FitWallet',
              style: TextStyle(
                fontSize: 32, 
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2
              ),
            ),
            const SizedBox(height: 8),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}