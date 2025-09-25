import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentPage extends StatefulWidget {
  final VoidCallback? onConsentSaved;
  ConsentPage({this.onConsentSaved});

  @override
  _ConsentPageState createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage> {
  bool _marketing = false;
  bool _touched = false;

  Future<void> _saveConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('marketing_consent', _marketing);
    widget.onConsentSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Consentimento de marketing', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 12),
          Text('Deseja receber comunicações de marketing?'),
          SizedBox(height: 24),
          SwitchListTile(
            title: Text('Concordo em receber marketing'),
            value: _marketing,
            onChanged: (v) => setState(() { _marketing = v; _touched = true; }),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _touched ? () async { await _saveConsent(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Consentimento salvo'))); } : null,
            child: Text('Confirmar'),
          )
        ],
      ),
    );
  }
}
