import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoToAccessPage extends StatelessWidget {
  final VoidCallback? onFinish;
  GoToAccessPage({this.onFinish});

  Future<void> _finish(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    onFinish?.call();
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Pronto para começar?'),
            SizedBox(height: 24),
            ElevatedButton(onPressed: () => _finish(context), child: Text('Ir para o acesso'))
          ],
        ),
      ),
    );
  }
}
