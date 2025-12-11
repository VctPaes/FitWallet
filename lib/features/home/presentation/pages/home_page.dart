import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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
        // Mantém a cor primária no AppBar para identidade visual consistente
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
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
                backgroundColor: theme.colorScheme.surface,
                child: userPhotoPath == null
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold),
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
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, List<Transacao> transacoes,
      double totalGasto, double meta, double disponivel) {
    
    // Detecta se é tema escuro para ajustar cores dos cards
    final isDark = theme.brightness == Brightness.dark;

    // Cores adaptativas para os cards
    final disponivelBg = isDark ? Colors.green.withOpacity(0.15) : const Color(0xFFE8F5E9);
    final disponivelText = isDark ? Colors.greenAccent.shade100 : Colors.green.shade800;
    
    final metaBg = isDark ? Colors.blue.withOpacity(0.15) : const Color(0xFFE3F2FD);
    final metaText = isDark ? Colors.lightBlueAccent.shade100 : Colors.blue.shade800;

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      onRefresh: () async {
        await Future.wait([
          context.read<TransactionProvider>().refreshTransactions(),
          context.read<UserProvider>().loadUsuario(),
          context.read<GoalProvider>().loadMeta(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Cabeçalho Circular (Donut)
            _buildCircularHeader(theme, totalGasto, meta),
            
            const SizedBox(height: 20),
            
            // Cards de Resumo (Meta e Disponível)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      theme, 
                      'Disponível', 
                      disponivel, 
                      disponivelBg,
                      disponivelText,
                      Icons.account_balance_wallet_outlined
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _alterarMetaSemanal(meta),
                      child: _buildInfoCard(
                        theme, 
                        'Meta Atual', 
                        meta, 
                        metaBg,
                        metaText,
                        Icons.flag_outlined
                      ),
                    )
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Título da Lista
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Últimas Despesas',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                    ),
                  ),
                  Text(
                    '${transacoes.length} total',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),

            // Lista de Transações
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TransactionListWidget(
                onTransactionTap: (transacao) {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => TransactionActionsSheet(transacao: transacao),
                  );
                },
              ),
            ),
            const SizedBox(height: 80), // Espaço para o FAB não cobrir o fim da lista
          ],
        ),
      ),
    );
  }

  // --- Widget: Header Circular Adaptativo ---
  Widget _buildCircularHeader(ThemeData theme, double totalGasto, double meta) {
    final double progresso = (meta > 0) ? totalGasto / meta : 0.0;
    final double progressoClamped = progresso.clamp(0.0, 1.0);
    
    // Cor de alerta se passar de 90%
    final Color progressColor = progressoClamped > 0.9 
      ? theme.colorScheme.error 
      : theme.colorScheme.primary;

    // Cor do texto secundário (cinza ou cinza claro dependendo do tema)
    final secondaryTextColor = theme.colorScheme.onSurface.withOpacity(0.6);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        // Usa a cor do "card" do tema, que adapta ao dark/light
        color: theme.cardColor, 
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Sombra sutil
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]
      ),
      child: Column(
        children: [
          Text(
            "ESTA SEMANA", 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              letterSpacing: 1.2,
              color: secondaryTextColor,
            )
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              // Fundo do círculo (trilho)
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 12,
                  // Cor de fundo do gráfico adaptativa
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.brightness == Brightness.dark 
                      ? Colors.white10 
                      : Colors.grey.shade100
                  ),
                ),
              ),
              // Progresso do círculo
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progressoClamped,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              // Texto Central
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Gasto',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${totalGasto.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface, // Texto principal adapta ao fundo
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(progresso * 100).toStringAsFixed(0)}% da meta',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Widget: Cards Coloridos Adaptativos ---
  Widget _buildInfoCard(ThemeData theme, String title, double value, Color bgColor, Color textColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w600
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontWeight: FontWeight.bold
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}