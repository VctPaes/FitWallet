import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../services/finance_service.dart';
import '../services/prefs_service.dart';
import 'add_gasto_page.dart';
import '../models/transacao.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  final PrefsService prefs;
  const HomePage({super.key, required this.prefs});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userPhotoPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _userPhotoPath = widget.prefs.getUserPhotoPath();
  }

  // --- Métodos de Ação do Avatar ---

  Future<void> _onEditAvatarPressed() async {
    Navigator.pop(context); 
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar Foto (Câmera)'),
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
            if (_userPhotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remover Foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  _removeImage();
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

      await widget.prefs.setUserPhotoPath(savedPath);
      setState(() {
        _userPhotoPath = savedPath;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao selecionar imagem. Tente novamente.')),
        );
      }
    }
  }

  Future<File?> _compressImage(XFile file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: 512,
      minHeight: 512,
      quality: 80,
      autoCorrectionAngle: true,
      keepExif: false,
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
    await imageFile.copy(newPath);
    return newPath;
  }

  Future<void> _removeImage() async {
    if (_userPhotoPath != null) {
      final file = File(_userPhotoPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    
    await widget.prefs.removeUserPhotoPath();
    setState(() {
      _userPhotoPath = null;
    });
  }

  // --- Métodos de Lógica (FitWallet) ---

  void _navegarParaAddGasto() async {
    final novaTransacao = await Navigator.push<Transacao>(
      context,
      MaterialPageRoute(builder: (context) => const AddGastoPage()),
    );

    if (novaTransacao != null) {
      context.read<FinanceService>().adicionarTransacao(novaTransacao);
    }
  }

  void _navegarParaEditarGasto(int index, Transacao transacao) async {
    final transacaoEditada = await Navigator.push<Transacao>(
      context,
      MaterialPageRoute(
        builder: (context) => AddGastoPage(transacaoParaEditar: transacao),
      ),
    );

    if (transacaoEditada != null) {
      context.read<FinanceService>().atualizarTransacao(index, transacaoEditada);
    }
  }

  void _mostrarOpcoesGasto(int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Wrap(children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Color(0xFF059669)),
            title: const Text('Alterar'),
            onTap: () {
              Navigator.pop(context);
              final transacao = context.read<FinanceService>().transacoes[index];
              _navegarParaEditarGasto(index, transacao);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Remover'),
            onTap: () {
              Navigator.pop(context);
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
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.read<FinanceService>().removerTransacao(index);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ]);
      },
    );
  }

  void _alterarMetaSemanal() {
    final financeService = context.read<FinanceService>();
    final controller = TextEditingController(
        text: financeService.metaSemanal.toStringAsFixed(2));
        
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
            onPressed: () {
              final novoValor = double.tryParse(controller.text.replaceAll(',', '.'));
              if (novoValor != null && novoValor > 0) {
                financeService.atualizarMeta(novoValor);
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // --- Build ---
  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceService>(
      builder: (context, financeService, child) {
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('FitWallet'),
            centerTitle: true,
            backgroundColor: theme.colorScheme.secondary, // Navy
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: _userPhotoPath != null
                      ? FileImage(File(_userPhotoPath!))
                      : null,
                  backgroundColor: theme.colorScheme.primary, // Emerald
                  child: _userPhotoPath == null
                      ? const Text(
                          'U', 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                        )
                      : null,
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
            userPhotoPath: _userPhotoPath,
            onEditAvatarPressed: _onEditAvatarPressed,
          ),
          body: _buildBody(financeService),
          floatingActionButton: FloatingActionButton(
            onPressed: _navegarParaAddGasto,
            backgroundColor: theme.colorScheme.primary, // Emerald
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  // --- Widgets do Corpo ---

  Widget _buildBody(FinanceService financeService) {
    final theme = Theme.of(context);
    final totalGasto = financeService.transacoes.fold(0.0, (sum, item) => sum + item.valor);
    final meta = financeService.metaSemanal;
    final disponivel = meta - totalGasto;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSearchBar(),
        const SizedBox(height: 24),
        _buildSummaryCards(theme, totalGasto, meta, disponivel),
        const SizedBox(height: 24),
        _buildProgressCard(theme, financeService, totalGasto, meta),
        const SizedBox(height: 24),
        Text(
          'Gastos Recentes',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.secondary, // Navy
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildTransacoesList(financeService),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        // Lógica de busca (pode ser implementada depois)
      },
    );
  }

  Widget _buildSummaryCards(ThemeData theme, double totalGasto, double meta, double disponivel) {
    final colorTotal = theme.colorScheme.secondary.withOpacity(0.1); // Fundo Navy
    final colorMeta = const Color(0xFFFFF7E0); // Amarelo/laranja claro
    final colorDisponivel = theme.colorScheme.primary.withOpacity(0.1); // Fundo Verde

    return Column(
      children: [
        // 1. Card da Meta (Largo, no topo)
        _buildSummaryCard(
          theme,
          'Meta Semanal',
          'R\$ ${meta.toStringAsFixed(2)}',
          Icons.flag_outlined,
          colorMeta,
        ),
        const SizedBox(height: 12),
        // 2. Row com os outros dois cards
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                theme,
                'Gasto Total',
                'R\$ ${totalGasto.toStringAsFixed(2)}',
                Icons.receipt_long_outlined,
                colorTotal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                theme,
                'Disponível',
                'R\$ ${disponivel.toStringAsFixed(2)}',
                disponivel >= 0 ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                colorDisponivel,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSummaryCard(ThemeData theme, String title, String value, IconData icon, Color backgroundColor) {
    return Card(
      elevation: 0,
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.secondary), // Ícone Navy
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(ThemeData theme, FinanceService financeService, double totalGasto, double meta) {
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
                Icon(Icons.show_chart, color: theme.colorScheme.primary), // Ícone Emerald
                const SizedBox(width: 8),
                Text(
                  'Progresso da Meta',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary, // Navy
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Você já usou R\$ ${totalGasto.toStringAsFixed(2)} da sua meta de R\$ ${meta.toStringAsFixed(2)}.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progressoClamped,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary), // Emerald
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progressoClamped * 100).toStringAsFixed(0)}% Completo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  onPressed: _alterarMetaSemanal,
                  tooltip: 'Alterar Meta',
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransacoesList(FinanceService financeService) {
    final transacoes = financeService.transacoes;
    final theme = Theme.of(context);

    if (transacoes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline, // Ícone de check
                size: 60,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum gasto aqui',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              Text(
                'Adicione um gasto usando o botão +',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transacoes.length,
      itemBuilder: (context, index) {
        final transacao = transacoes[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: Icon(transacao.icone, color: theme.colorScheme.primary), // Emerald
            title: Text(transacao.titulo),
            trailing: Text(
              '- R\$ ${transacao.valor.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _mostrarOpcoesGasto(index),
          ),
        );
      },
    );
  }
}