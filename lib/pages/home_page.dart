import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/refeicao.dart';
import '../services/meal_service.dart';
import '../services/prefs_service.dart';

class HomePage extends StatefulWidget {
  final PrefsService prefs;
  const HomePage({super.key, required this.prefs});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Set<String> _preferenciasSelecionadas = {};
  final List<String> _todasPreferencias = ['Rápido', 'Saudável', 'Vegetariano'];

  @override
  Widget build(BuildContext context) {
    final mealService = context.watch<MealService>();
    final planoGerado = mealService.planoSemanal;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('MealPrep Lite'),
      ),
      endDrawer: _buildDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            '1. Escolha suas preferências',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: _todasPreferencias.map((preferencia) {
              final isSelected = _preferenciasSelecionadas.contains(preferencia);
              return FilterChip(
                label: Text(preferencia),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _preferenciasSelecionadas.add(preferencia);
                    } else {
                      _preferenciasSelecionadas.remove(preferencia);
                    }
                  });
                },
                selectedColor: theme.colorScheme.primary.withOpacity(0.3),
                checkmarkColor: theme.colorScheme.secondary,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Gerar Cardápio Semanal'),
              onPressed: () {
                context.read<MealService>().gerarPlano(_preferenciasSelecionadas);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 32),

          if (planoGerado.isNotEmpty) ...[
            Text(
              '2. Seu plano base para a semana!',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 12),
            ...planoGerado.map((refeicao) => _buildRefeicaoCard(refeicao, theme)).toList(),
          ]
        ],
      ),
    );
  }

  Widget _buildRefeicaoCard(Refeicao refeicao, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              refeicao.tipo.toUpperCase(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary.withOpacity(0.7),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              refeicao.nome,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            if (refeicao.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                children: refeicao.tags.map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: theme.colorScheme.primary.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.bold
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  side: BorderSide.none,
                )).toList(),
              )
            ]
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
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
    );
  }
}