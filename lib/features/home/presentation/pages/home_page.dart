import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

import '../../../../core/services/prefs_service.dart';
import '../../../../core/presentation/widgets/drawer/app_drawer.dart';

import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../transaction/domain/entities/transacao.dart';
import '../../../transaction/presentation/pages/add_gasto_page.dart';
import '../../../transaction/presentation/widgets/transaction_list_widget.dart';
import '../../../transaction/presentation/widgets/transaction_actions_sheet.dart';

import '../../../goal/presentation/providers/goal_provider.dart';

import '../../../user/presentation/providers/user_provider.dart';

class HomePage extends StatefulWidget {
  final PrefsService prefs;
  const HomePage({super.key, required this.prefs});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<GoalProvider>().loadMeta();
      context.read<UserProvider>().loadUsuario();
    });
  }

  void _navegarParaAddGasto() async {
    final novaTransacao = await Navigator.push<Transacao>(
      context,
      MaterialPageRoute(builder: (context) => const AddGastoPage()),
    );

    if (novaTransacao != null && mounted) {
      try {
        await context.read<TransactionProvider>().addTransaction(novaTransacao);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto adicionado com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao adicionar: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _alterarMetaSemanal(double valorAtual) {
    final controller =
        TextEditingController(text: valorAtual.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Meta Semanal'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Nova meta',
            prefixText: 'R\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final novoValor =
                  double.tryParse(controller.text.replaceAll(',', '.'));
              if (novoValor != null && novoValor > 0) {
                await context.read<GoalProvider>().updateMeta(novoValor);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _onEditAvatarPressed() async {
    Navigator.pop(context);
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar Foto'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da Galeria'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            Consumer<UserProvider>(
              builder: (ctx, userProvider, _) {
                if (userProvider.usuario?.fotoPath != null) {
                  return ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Remover Foto',
                        style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.of(context).pop();
                      _removeImage();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();

      final extension = p.extension(pickedFile.path).replaceAll('.', '');

      if (mounted) {
        await context.read<UserProvider>().atualizarFoto(bytes, extension);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto atualizada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar foto: $e')),
        );
      }
    }
  }

  Future<void> _removeImage() async {
    final userProvider = context.read<UserProvider>();
    final currentPath = userProvider.usuario?.fotoPath;

    if (currentPath != null) {
      final file = File(currentPath);
      if (await file.exists()) await file.delete();
    }

    await userProvider.removerFoto();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final transactionProvider = context.watch<TransactionProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final userProvider = context.watch<UserProvider>();

    final usuario = userProvider.usuario;
    final userPhotoPath = usuario?.fotoPath;
    final userName = usuario?.nome ?? 'Estudante';

    final transacoes = transactionProvider.transacoes;
    final totalGasto = transacoes.fold(0.0, (sum, item) => sum + item.valor);
    final metaValor = goalProvider.meta?.valor ?? 0.0;
    final disponivel = metaValor - totalGasto;

    final bool isLoading =
        transactionProvider.isLoading || goalProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitWallet'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.secondary,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: userPhotoPath != null
                    ? (userPhotoPath.startsWith('http')
                        ? NetworkImage(userPhotoPath)
                        : FileImage(File(userPhotoPath)) as ImageProvider)
                    : null,
                backgroundColor: Colors.white,
                child: userPhotoPath == null
                    ? Text(
                        userName[0].toUpperCase(),
                        style: TextStyle(
                            color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        onEditAvatarPressed: _onEditAvatarPressed,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(theme, transacoes, totalGasto, metaValor, disponivel),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarParaAddGasto,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, List<Transacao> transacoes,
      double totalGasto, double meta, double disponivel) {
    return RefreshIndicator(
      color: theme.colorScheme.primary,
      onRefresh: () async {
        await Future.wait([
          context.read<TransactionProvider>().refreshTransactions(),
          context.read<UserProvider>().loadUsuario(),
          context.read<GoalProvider>().loadMeta(),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildSummaryCards(theme, totalGasto, meta, disponivel),
          const SizedBox(height: 24),
          _buildProgressCard(theme, totalGasto, meta),
          const SizedBox(height: 24),
          Text(
            'Gastos Recentes',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TransactionListWidget(
            onTransactionTap: (transacao) {
              showModalBottomSheet(
                context: context,
                builder: (_) => TransactionActionsSheet(transacao: transacao),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar gastos...',
        hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
        prefixIcon: Icon(Icons.search,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
        filled: true,
        fillColor:
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none),
      ),
      onChanged: (value) {/* Implementar filtro no TransactionProvider */},
    );
  }

  Widget _buildSummaryCards(
      ThemeData theme, double totalGasto, double meta, double disponivel) {
    return Column(
      children: [
        _buildSummaryCard(
          theme,
          'Meta Semanal',
          'R\$ ${meta.toStringAsFixed(2)}',
          Icons.flag_outlined,
          const Color(0xFFFFF7E0),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildSummaryCard(
                    theme,
                    'Gasto Total',
                    'R\$ ${totalGasto.toStringAsFixed(2)}',
                    Icons.receipt_long_outlined,
                    theme.colorScheme.secondary.withOpacity(0.1))),
            const SizedBox(width: 12),
            Expanded(
                child: _buildSummaryCard(
                    theme,
                    'Disponível',
                    'R\$ ${disponivel.toStringAsFixed(2)}',
                    disponivel >= 0
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_outlined,
                    theme.colorScheme.primary.withOpacity(0.1))),
          ],
        )
      ],
    );
  }

  Widget _buildSummaryCard(
      ThemeData theme, String title, String value, IconData icon, Color bg) {
    return Card(
      elevation: 0,
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.secondary),
            const SizedBox(height: 8),
            Text(value,
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(title,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(ThemeData theme, double totalGasto, double meta) {
    final double progresso = (meta > 0) ? totalGasto / meta : 0.0;
    final double progressoClamped = progresso.clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Progresso da Meta',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
                'Você já usou R\$ ${totalGasto.toStringAsFixed(2)} da sua meta de R\$ ${meta.toStringAsFixed(2)}.',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7))),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progressoClamped,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(progressoClamped * 100).toStringAsFixed(0)}% Completo',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.edit,
                      size: 20,
                      color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  onPressed: () => _alterarMetaSemanal(meta),
                  tooltip: 'Alterar Meta',
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
