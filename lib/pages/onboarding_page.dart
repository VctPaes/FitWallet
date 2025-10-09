import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

class OnboardingPage extends StatefulWidget {
  final PrefsService prefs;
  const OnboardingPage({super.key, required this.prefs});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;
  bool _policyRead = false; // controle se a política foi lida até o fim

  void _next() {
    if (_index < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      widget.prefs.setOnboardingCompleted(true);
      Navigator.of(context).pushReplacementNamed('/consent');
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacementNamed('/consent');
  }

  Future<void> _showPrivacyPolicy() async {
    bool reachedEnd = false;
    final controller = ScrollController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          controller.addListener(() {
            if (controller.offset >= controller.position.maxScrollExtent &&
                !reachedEnd) {
              setState(() {
                reachedEnd = true;
              });
            }
          });

          return AlertDialog(
            title: const Text('Política de Privacidade'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Scrollbar(
                thumbVisibility: true,
                controller: controller,
                child: SingleChildScrollView(
                  controller: controller,
                  child: const Text(
                    '''
FitWallet — Política de Privacidade

1. Coleta de Dados:
Coletamos apenas informações necessárias para o funcionamento do aplicativo, como preferências locais e dados de gastos salvos no próprio dispositivo. Não há envio de informações a servidores externos.

2. Uso dos Dados:
Os dados são utilizados exclusivamente para personalizar a experiência do usuário e armazenar informações de forma local (no seu dispositivo).

3. Consentimento:
O consentimento de marketing é opcional. O usuário pode revogar a qualquer momento em "Configurações" → "Limpar Consentimento".

4. Direitos do Usuário:
De acordo com a LGPD, você pode solicitar a exclusão dos dados locais a qualquer momento.

5. Contato:
Em caso de dúvidas sobre a política, entre em contato com o suporte FitWallet.

Ao rolar até o fim e clicar em "Concordo com os Termos", você reconhece que leu e aceita esta política.
                    ''',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: reachedEnd
                    ? () {
                        setState(() => _policyRead = true);
                        Navigator.of(ctx).pop();
                      }
                    : null,
                child: const Text('Concordo com os Termos'),
              ),
            ],
          );
        },
      ),
    );

    setState(() {});
  }

  Widget _buildPage({required String title, required String body, Widget? extra}) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(body,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          if (extra != null) extra,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildPage(
        title: 'Bem-vindo ao FitWallet',
        body:
            'Finanças rápidas para estudantes — comece a controlar seus gastos em segundos.',
      ),
      _buildPage(
        title: 'Como funciona',
        body:
            'Registre gastos diários com categorias mínimas. Acompanhe sua meta semanal e veja seu progresso.',
      ),
      _buildPage(
        title: 'Privacidade & LGPD',
        body:
            'Para usar o FitWallet, é necessário ler e aceitar nossa Política de Privacidade.',
        extra: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.privacy_tip_outlined),
              label: const Text('Ver Política de Privacidade'),
              onPressed: _showPrivacyPolicy,
            ),
            const SizedBox(height: 8),
            Text(
              _policyRead
                  ? '✔ Política lida e aceita.'
                  : 'Você deve ler a política até o final para prosseguir.',
              style: TextStyle(
                color: _policyRead
                    ? Colors.green.shade700
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
      _buildPage(
        title: 'Primeiros passos',
        body:
            'Defina sua meta semanal simples e adicione seu primeiro gasto para começar.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding'),
        actions: [
          TextButton(
            onPressed: _skip,
            child: const Text(
              'Pular',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              children: pages,
            ),
          ),
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _index > 0
                      ? () => _controller.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          )
                      : null,
                  child: const Text('Voltar'),
                ),
                Row(
                  children: List.generate(
                    4,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: i == _index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ElevatedButton(
                    onPressed: _index == 2 && !_policyRead
                        ? null // bloqueia avanço até ler a política
                        : _next,
                    child: Text(_index < 3 ? 'Avançar' : 'Finalizar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
