import 'package:flutter/material.dart';
import '../../../../core/services/prefs_service.dart';
import '../../../../core/constants/legal_texts.dart';
import '../../../../core/presentation/widgets/policy_dialog.dart'; 

// --- PÁGINA PRINCIPAL DO ONBOARDING ---

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
  bool _termsRead = false;
  bool _allAgreed = false; 

  @override
  void initState() {
    super.initState();
    final initialConsent = widget.prefs.getMarketingConsent();
    _allAgreed = initialConsent;
    _policyRead = initialConsent;
    _termsRead = initialConsent;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        final startAtPage = args['startAtPage'] as int? ?? 0;
        final forcedConsent = args['initialConsent'] as bool? ?? _allAgreed;
        _controller.jumpToPage(startAtPage);
        setState(() {
          _policyRead = forcedConsent;
          _termsRead = forcedConsent;
          _allAgreed = forcedConsent;
        });
      }
    });
  }

  // --- MÉTODOS DE CONTROLE ---

  Future<void> _next() async {
    if (_index < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      await widget.prefs.setMarketingConsent(_allAgreed);
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
      builder: (ctx) => const PolicyDialog(
        title: 'Política de Privacidade - FitWallet',
        content: privacyPolicyContent,
      ),
    );

    if (userAgreed == true) {
      setState(() {
        _policyRead = true;
        if (_termsRead) {
          _allAgreed = true;
        }
      });
    }
  }

  Future<void> _showTermsOfUse() async {
    final bool? userAgreed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const PolicyDialog(
        title: 'Termos de Uso - FitWallet',
        content: termsOfUseContent,
      ),
    );

    if (userAgreed == true) {
      setState(() {
        _termsRead = true;
        if (_policyRead) {
          _allAgreed = true;
        }
      });
    }
  }

  // --- CONSTRUÇÃO DA UI ---

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
    final bool allDocsRead = _policyRead && _termsRead;
    
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
        title: 'Política e Consentimento',
        body: 'Antes de continuar, leia e aceite nossa Política de Privacidade e Termos de Uso.',
        extra: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.privacy_tip_outlined),
              label: const Text('Ler Política de Privacidade'),
              onPressed: _showPrivacyPolicy,
              style: ElevatedButton.styleFrom(minimumSize: const Size(240, 40)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.gavel_outlined),
              label: const Text('Ler Termos de Uso'),
              onPressed: _showTermsOfUse,
              style: ElevatedButton.styleFrom(minimumSize: const Size(240, 40)),
            ),
            const SizedBox(height: 24),
            
            Opacity(
              opacity: allDocsRead ? 1.0 : 0.5,
              child: SwitchListTile(
                title: const Text('Li e concordo com a Política de Privacidade e os Termos de Uso'),
                value: _allAgreed,
                onChanged: allDocsRead
                    ? (value) => setState(() => _allAgreed = value)
                    : null,
              ),
            ),
            
            if (!allDocsRead)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Você precisa ler ambos os documentos antes de poder aceitar.',
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

    final isPrivacyPageBlocked = (_index == 2 && !_allAgreed);

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
                      child: Text('PULAR', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
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
                  
                  Visibility(
                    visible: _index < pages.length - 1,
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: true,
                    child: Row(
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
