import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

class HomePage extends StatefulWidget {
  final PrefsService prefs;
  const HomePage({super.key, required this.prefs});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int weeklyGoal = 0;
  List<Map<String, dynamic>> expenses = [];
  String? consentDate;

  @override
  void initState() {
    super.initState();
    weeklyGoal = widget.prefs.weeklyGoal;
    final json = widget.prefs.expensesJson;
    if (json != null) {
      final list = jsonDecode(json) as List<dynamic>;
      expenses = List<Map<String, dynamic>>.from(list);
    }
    consentDate = widget.prefs.consentAcceptedAt;
  }

  Future<void> _saveExpenses() async {
    await widget.prefs.setExpensesJson(jsonEncode(expenses));
  }

  Future<void> _setGoal() async {
    final controller =
        TextEditingController(text: weeklyGoal == 0 ? '' : weeklyGoal.toString());
    final res = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Meta semanal (R\$)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Ex: 100'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () {
                final v = int.tryParse(controller.text) ?? 0;
                Navigator.of(ctx).pop(v);
              },
              child: const Text('Salvar')),
        ],
      ),
    );
    if (res != null) {
      setState(() => weeklyGoal = res);
      await widget.prefs.setWeeklyGoal(res);
    }
  }

  Future<void> _addExpense() async {
    final titleController = TextEditingController();
    final valueController = TextEditingController();
    final res = await showDialog<bool?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar gasto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Descrição')),
            TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor (R\$)')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Adicionar')),
        ],
      ),
    );
    if (res == true) {
      final title = titleController.text.isEmpty ? 'Gasto' : titleController.text;
      final value =
          double.tryParse(valueController.text.replaceAll(',', '.')) ?? 0.0;
      final item = {
        'title': title,
        'value': value,
        'date': DateTime.now().toIso8601String()
      };
      setState(() {
        expenses.insert(0, item);
      });
      await _saveExpenses();
    }
  }

  Future<void> _removeExpense(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover gasto'),
        content: const Text('Tem certeza que deseja remover este gasto?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Remover')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        expenses.removeAt(index);
      });
      await _saveExpenses();
    }
  }

  Future<void> _redoOnboarding() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Refazer onboarding'),
        content: const Text(
            'Deseja realmente refazer o onboarding? Isso limpará seu progresso inicial e pedirá novo consentimento.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Refazer')),
        ],
      ),
    );

    if (confirm == true) {
      await widget.prefs.setOnboardingCompleted(false);
      await widget.prefs.setMarketingConsent(false);
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/onboarding', (route) => false);
      }
    }
  }

  Future<void> _clearConsent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revogar consentimento'),
        content: const Text(
            'Deseja revogar seu consentimento de marketing? Você pode conceder novamente ao refazer o onboarding.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Revogar')),
        ],
      ),
    );

    if (confirm == true) {
      await widget.prefs.setMarketingConsent(false);
      setState(() => consentDate = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consentimento revogado com sucesso.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSpent =
        expenses.fold<double>(0.0, (s, e) => s + (e['value'] as double));
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitWallet'),
        actions: [
          IconButton(
            tooltip: 'Configurar meta',
            onPressed: _setGoal,
            icon: const Icon(Icons.flag),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Meta semanal'),
                subtitle: Text('R\$ $weeklyGoal'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Gasto: R\$ ${totalSpent.toStringAsFixed(2)}'),
                    Text(
                        'Restante: R\$ ${(weeklyGoal - totalSpent).toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _addExpense,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar gasto'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: expenses.isEmpty
                  ? const Center(child: Text('Nenhum gasto registrado.'))
                  : ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (ctx, i) {
                        final e = expenses[i];
                        return Card(
                          child: ListTile(
                            title: Text(e['title']),
                            subtitle:
                                Text(e['date'].toString().split('T').first),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    'R\$ ${(e['value'] as double).toStringAsFixed(2)}'),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  tooltip: 'Remover gasto',
                                  onPressed: () => _removeExpense(i),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            if (consentDate != null)
              Text(
                'Consentimento concedido em: ${DateTime.parse(consentDate!).toLocal().toString().split(".").first}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            SafeArea(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.replay),
                    label: const Text('Refazer Onboarding'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    onPressed: _redoOnboarding,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.privacy_tip_outlined),
                    label: const Text('Limpar Consentimento'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.errorContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    onPressed: _clearConsent,
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
