import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

class ConsentPage extends StatefulWidget {
  final PrefsService prefs;
  const ConsentPage({super.key, required this.prefs});

  @override
  State<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage> {
  bool _marketing = false;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _marketing = widget.prefs.marketingConsent;
  }

  void _confirm() async {
    await widget.prefs.setMarketingConsent(_marketing);
    await widget.prefs.setOnboardingCompleted(true);
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consentimento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Política de Privacidade — LGPD (resumo)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              'Coletamos apenas o necessário para a funcionalidade local do app. '
              'O consentimento para marketing é opcional e pode ser revogado nas configurações.',
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Concordo em receber informações/marketing'),
              value: _marketing,
              onChanged: (v) => setState(() { _marketing = v; _touched = true; }),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _touched ? _confirm : null,
              child: const Text('Confirmar'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
