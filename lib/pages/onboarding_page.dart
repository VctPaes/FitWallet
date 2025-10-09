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
  bool _policyRead = false;
  bool _policyAgreed = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return; 

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final initialConsent = widget.prefs.getMarketingConsent();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _policyRead = initialConsent;
        _policyAgreed = initialConsent;
      });

      if (args != null) {
        final startAtPage = args['startAtPage'] as int? ?? 0;
        final forcedConsent = args['initialConsent'] as bool? ?? initialConsent;

        _controller.jumpToPage(startAtPage);
        setState(() {
          _policyRead = forcedConsent;
          _policyAgreed = forcedConsent;
        });
      }
      _initialized = true;
    });
  }

  Future<void> _next() async {
    if (_index < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      await widget.prefs.setMarketingConsent(_policyAgreed);
      await widget.prefs.setOnboardingCompleted(true);
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _skip() {
    _controller.animateToPage(
      2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Future<void> _showPrivacyPolicy() async {
    bool reachedEnd = false;
    final controller = ScrollController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: const Text('Política de Privacidade'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Scrollbar(
                thumbVisibility: true,
                controller: controller,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    final metrics = scrollNotification.metrics;
                    if (metrics.pixels >= metrics.maxScrollExtent &&
                        !reachedEnd) {
                      setStateDialog(() {
                        reachedEnd = true;
                      });
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: controller,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '''
FitWallet — Política de Privacidade

1. Coleta de Dados:
Coletamos apenas informações necessárias para o funcionamento do aplicativo, como preferências locais e dados de gastos salvos no próprio dispositivo. Não há envio de informações a servidores externos.

2. Uso dos Dados:
Os dados são utilizados exclusivamente para personalizar a experiência do usuário e armazenar informações de forma local (no seu dispositivo).

3. Consentimento:
O consentimento é dado ao aceitar esta política. O usuário pode revogar a qualquer momento em "Limpar Consentimento" no menu lateral.

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
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: reachedEnd
                    ? () async {
                        await widget.prefs.setMarketingConsent(true);

                        if (mounted) {
                          setState(() {
                            _policyRead = true;
                            _policyAgreed = true;
                          });
                        }

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

  }

  Widget _buildPage({
    required String title,
    required String body,
    Widget? extra,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
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
            'Antes de continuar, leia e aceite nossa Política de Privacidade.',
        extra: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.privacy_tip_outlined),
              label: const Text('Ver Política de Privacidade'),
              onPressed: _showPrivacyPolicy,
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: _policyRead ? 1.0 : 0.6,
              child: SwitchListTile(
                title: const Text('Concordo com a Política de Privacidade'),
                value: _policyAgreed,
                onChanged: _policyRead
                    ? (v) async {
                        await widget.prefs.setMarketingConsent(v);
                        final saved = widget.prefs.getMarketingConsent();
                        setState(() {
                          _policyAgreed = saved;
                        });
                      }
                    : null,
              ),
            ),
            if (!_policyRead)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Você precisa ler a política até o final antes de poder aceitar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.redAccent),
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

    final ScrollPhysics pagePhysics = (_index == 2 && !_policyAgreed)
        ? const NeverScrollableScrollPhysics()
        : const AlwaysScrollableScrollPhysics();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding'),
        actions: [
          if (_index < 2)
            TextButton(
              onPressed: _skip,
              child:
                  const Text('Pular', style: TextStyle(color: Colors.white)),
            )
          else
            const SizedBox(width: 60),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              physics: pagePhysics,
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
                    onPressed: _index == 2 && !_policyAgreed ? null : _next,
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
