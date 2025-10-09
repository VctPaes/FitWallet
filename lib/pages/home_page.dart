import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

class HomePage extends StatefulWidget {
  final PrefsService prefs;
  const HomePage({super.key, required this.prefs});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitWallet'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Configurações',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refazer Onboarding'),
              subtitle: const Text('Sem limpar consentimento'),
              onTap: () async {
                Navigator.pop(context);
                await widget.prefs.setOnboardingCompleted(false);

                
                bool currentConsent = widget.prefs.getMarketingConsent();

                Navigator.of(context).pushReplacementNamed(
                  '/onboarding',
                  arguments: {
                    'startAtPage': 0,
                    'initialConsent': currentConsent,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Limpar Consentimento'),
              subtitle: const Text('Revogar aceite da política'),
              onTap: () async {
                Navigator.pop(context);

                await widget.prefs.setMarketingConsent(false);

                Navigator.of(context).pushReplacementNamed(
                  '/onboarding',
                  arguments: {
                    'startAtPage': 2,
                    'initialConsent': false,
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Bem-vindo ao FitWallet 💰\n\nControle suas finanças de forma simples e rápida!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
