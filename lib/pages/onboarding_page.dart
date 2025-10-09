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

  @override
  void initState() {
    super.initState();
    _policyAgreed = widget.prefs.getMarketingConsent();
    _policyRead = _policyAgreed;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        final startAtPage = args['startAtPage'] as int? ?? 0;
        final forcedConsent = args['initialConsent'] as bool? ?? _policyAgreed;
        _controller.jumpToPage(startAtPage);
        setState(() {
          _policyRead = forcedConsent;
          _policyAgreed = forcedConsent;
        });
      }
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
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
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
    final bool? userAgreed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _PrivacyPolicyDialog(),
    );

    if (userAgreed == true) {
      setState(() {
        _policyRead = true;
        _policyAgreed = true;
      });
    }
  }

  Widget _buildPage({
    String? imagePath,
    required String title,
    required String body,
    Widget? extra,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imagePath != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Image.asset(
                imagePath,
                height: 220,
              ),
            ),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (extra != null) extra,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildPage(
        imagePath: 'assets/images/onboarding1.png',
        title: 'Bem-vindo ao FitWallet',
        body: 'Finanças rápidas para estudantes — comece a controlar seus gastos em segundos.',
      ),
      _buildPage(
        imagePath: 'assets/images/onboarding2.png',
        title: 'Como funciona',
        body: 'Registre gastos diários com categorias mínimas. Acompanhe sua meta semanal e veja seu progresso.',
      ),
      _buildPage(
        title: 'Privacidade & LGPD',
        body: 'Antes de continuar, por favor, leia e aceite nossa Política de Privacidade.',
        extra: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.privacy_tip_outlined),
              label: const Text('Ler Política de Privacidade'),
              onPressed: _showPrivacyPolicy,
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: _policyRead ? 1.0 : 0.5,
              child: SwitchListTile(
                title: const Text('Concordo com a Política de Privacidade'),
                value: _policyAgreed,
                onChanged: _policyRead
                    ? (value) => setState(() => _policyAgreed = value)
                    : null,
              ),
            ),
            if (!_policyRead)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Você precisa ler a política até o final para poder aceitar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
      _buildPage(
        imagePath: 'assets/images/onboarding4.png',
        title: 'Tudo pronto!',
        body: 'Defina sua meta semanal e adicione seu primeiro gasto para começar a ter o controle.',
      ),
    ];

    final isPrivacyPageBlocked = (_index == 2 && !_policyAgreed);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 56,
              alignment: Alignment.centerRight,
              child: _index < 2
                  ? TextButton(
                      onPressed: _skip,
                      child: const Text('PULAR'),
                    )
                  : const SizedBox(height: 56),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                physics: isPrivacyPageBlocked
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                children: pages,
              ),
            ),
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    child: const Text('VOLTAR'),
                  ),
                  Row(
                    children: List.generate(
                      pages.length,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: i == _index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isPrivacyPageBlocked ? null : _next,
                    child: Text(_index < pages.length - 1 ? 'AVANÇAR' : 'FINALIZAR'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyPolicyDialog extends StatefulWidget {
  const _PrivacyPolicyDialog();
  @override
  State<_PrivacyPolicyDialog> createState() => _PrivacyPolicyDialogState();
}
class _PrivacyPolicyDialogState extends State<_PrivacyPolicyDialog> {
  bool _reachedEnd = false;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  void _onScroll() {
    if (!_reachedEnd && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      setState(() {
        _reachedEnd = true;
      });
    }
  }
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Política de Privacidade'),
      content: SizedBox(
        width: double.maxFinite,
        child: Scrollbar(
          thumbVisibility: true,
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: const Text(
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

Ao clicar em "Concordo", você confirma que leu e aceita esta Política de Privacidade.
              ''',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _reachedEnd
              ? () => Navigator.of(context).pop(true)
              : null,
          child: const Text('Concordo'),
        ),
      ],
    );
  }
}