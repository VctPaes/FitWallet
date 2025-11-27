import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../../core/services/prefs_service.dart';
import '../../../../core/presentation/widgets/app_drawer.dart';

// --- Imports das Features (Clean Architecture) ---
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../transaction/domain/entities/transacao.dart';
import '../../../transaction/presentation/pages/add_gasto_page.dart';
import '../../../category/presentation/providers/category_provider.dart';

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
    
    // Garante que os dados estejam frescos ao abrir a Home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<GoalProvider>().loadMeta();
      context.read<UserProvider>().loadUsuario();
    });
  }

  // --- Métodos de Ação (Transação) ---

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
          SnackBar(content: Text('Erro ao adicionar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _navegarParaEditarGasto(Transacao transacao) async {
    final transacaoEditada = await Navigator.push<Transacao>(
      context,
      MaterialPageRoute(
        builder: (context) => AddGastoPage(transacaoParaEditar: transacao),
      ),
    );

    if (transacaoEditada != null && mounted) {
      await context.read<TransactionProvider>().updateTransaction(transacaoEditada);
    }
  }

  void _confirmarRemocao(Transacao transacao) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Remoção'),
        content: const Text('Você tem certeza que deseja remover este gasto?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Fecha Dialog
              await context.read<TransactionProvider>().deleteTransaction(transacao.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gasto removido.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _mostrarOpcoesGasto(Transacao transacao) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF059669)),
              title: const Text('Alterar'),
              onTap: () {
                Navigator.pop(context);
                _navegarParaEditarGasto(transacao);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remover'),
              onTap: () {
                Navigator.pop(context);
                _confirmarRemocao(transacao);
              },
            ),
          ]),
        );
      },
    );
  }

  // --- Métodos de Ação (Meta) ---

  void _alterarMetaSemanal(double valorAtual) {
    final controller = TextEditingController(text: valorAtual.toStringAsFixed(2));
        
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
              final novoValor = double.tryParse(controller.text.replaceAll(',', '.'));
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

  // --- Métodos de Ação (Usuário/Avatar) ---

  Future<void> _onEditAvatarPressed() async {
    Navigator.pop(context); // Fecha o Drawer
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
            // Verifica se tem foto para mostrar opção de remover
            Consumer<UserProvider>(
              builder: (ctx, userProvider, _) {
                if (userProvider.usuario?.fotoPath != null) {
                  return ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Remover Foto', style: TextStyle(color: Colors.red)),
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

      final File? compressedFile = await _compressImage(pickedFile);
      if (compressedFile == null) return;

      final String savedPath = await _saveImageLocally(compressedFile);

      // Atualiza via Provider
      if (mounted) {
        await context.read<UserProvider>().atualizarFoto(savedPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro na imagem. Tente novamente.')),
        );
      }
    }
  }

  Future<File?> _compressImage(XFile file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: 512, minHeight: 512, quality: 80,
      autoCorrectionAngle: true, keepExif: false,
    );
    if (result == null) return null;
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, 'temp_compressed.jpg'));
    await tempFile.writeAsBytes(result);
    return tempFile;
  }

  Future<String> _saveImageLocally(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final String newPath = p.join(directory.path, 'avatar.jpg');
    // Se já existir, deleta antes de sobrescrever
    if (await File(newPath).exists()) await File(newPath).delete();
    await imageFile.copy(newPath);
    return newPath;
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

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Consumindo os Providers
    final transactionProvider = context.watch<TransactionProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final userProvider = context.watch<UserProvider>();

    // Dados
    final transacoes = transactionProvider.transacoes;
    final totalGasto = transacoes.fold(0.0, (sum, item) => sum + item.valor);
    final metaValor = goalProvider.meta?.valor ?? 0.0;
    final disponivel = metaValor - totalGasto;
    final userPhotoPath = userProvider.usuario?.fotoPath;

    final bool isLoading = transactionProvider.isLoading || goalProvider.isLoading;

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
                    ? FileImage(File(userPhotoPath))
                    : null,
                backgroundColor: theme.colorScheme.primary,
                child: userPhotoPath == null
                    ? const Text('U', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
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
        // O AppDrawer agora busca a foto internamente via Provider,
        // mas mantemos o callback de edição
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

  Widget _buildBody(ThemeData theme, List<Transacao> transacoes, double totalGasto, double meta, double disponivel) {
    return ListView(
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
        _buildTransacoesList(theme, transacoes),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar gastos...',
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
        prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
      ),
      onChanged: (value) { /* Implementar filtro no TransactionProvider */ },
    );
  }

  Widget _buildSummaryCards(ThemeData theme, double totalGasto, double meta, double disponivel) {
    return Column(
      children: [
        _buildSummaryCard(
          theme, 'Meta Semanal', 'R\$ ${meta.toStringAsFixed(2)}',
          Icons.flag_outlined, const Color(0xFFFFF7E0),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSummaryCard(theme, 'Gasto Total', 'R\$ ${totalGasto.toStringAsFixed(2)}', Icons.receipt_long_outlined, theme.colorScheme.secondary.withOpacity(0.1))),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard(theme, 'Disponível', 'R\$ ${disponivel.toStringAsFixed(2)}', disponivel >= 0 ? Icons.check_circle_outline : Icons.warning_amber_outlined, theme.colorScheme.primary.withOpacity(0.1))),
          ],
        )
      ],
    );
  }

  Widget _buildSummaryCard(ThemeData theme, String title, String value, IconData icon, Color bg) {
    return Card(
      elevation: 0, color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.secondary),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
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
                Text('Progresso da Meta', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Você já usou R\$ ${totalGasto.toStringAsFixed(2)} da sua meta de R\$ ${meta.toStringAsFixed(2)}.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progressoClamped,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              minHeight: 8, borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(progressoClamped * 100).toStringAsFixed(0)}% Completo', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.edit, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.5)),
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

  Widget _buildTransacoesList(ThemeData theme, List<Transacao> transacoes) {
    if (transacoes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, size: 60, color: theme.colorScheme.onSurface.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text('Nenhum gasto aqui', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.8))),
              Text('Adicione um gasto usando o botão +', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      itemBuilder: (context, index) {
        final transacao = transacoes[index];
  
        // Busca a categoria completa pelo ID da transação
        final categoryProvider = context.read<CategoryProvider>();
        final categoria = categoryProvider.getCategoriaById(transacao.categoriaId);
  
        // Define ícone e cor (com fallback se não encontrar)
        final iconData = categoria != null 
            ? CategoryProvider.getIconFromKey(categoria.iconKey) 
            : Icons.help_outline;
      
       final iconColor = categoria != null 
            ? Color(categoria.corHex) 
            : theme.colorScheme.primary;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            // Agora usa os dados dinâmicos
            leading: Icon(iconData, color: iconColor),
            title: Text(transacao.titulo),
            // ... resto do código igual
          ),
        );
      },
    );
  }
}