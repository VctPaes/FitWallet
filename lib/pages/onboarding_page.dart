import 'package:flutter/material.dart';
import '../widgets/dots_indicator.dart';
import 'consent_page.dart';
import 'go_to_access_page.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final int _pages = 4;

  void _goToConsent() => _controller.animateToPage(2, duration: Duration(milliseconds: 300), curve: Curves.ease);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        if (_currentPage != _pages - 1)
          TextButton(onPressed: () => _goToConsent(), child: Text('Pular'))
      ]),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildWelcome(),
                  _buildHowItWorks(),
                  ConsentPage(onConsentSaved: () {}),
                  GoToAccessPage(onFinish: () {}),
                ],
              ),
            ),
            if (_currentPage != _pages - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: DotsIndicator(count: _pages, index: _currentPage),
              ),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    final isFirst = _currentPage == 0;
    final isLast = _currentPage == _pages - 1;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Visibility(
            visible: !isFirst && !isLast,
            child: ElevatedButton(
              onPressed: !isFirst ? () => _controller.previousPage(duration: Duration(milliseconds: 300), curve: Curves.ease) : null,
              child: Text('Voltar'),
            ),
          ),
          Spacer(),
          Visibility(
            visible: !isLast,
            child: ElevatedButton(
              onPressed: () => _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease),
              child: Text('Avançar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() => Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Bem-vindo!')));
  Widget _buildHowItWorks() => Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Como funciona')));
}
