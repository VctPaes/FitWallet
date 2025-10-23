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

  // --- Lógica de seleção e salvamento de imagem ---

  Future<void> _onEditAvatarPressed() async {
    Navigator.pop(context); // Fecha o drawer
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

  // ▼▼▼ ERRO 1 CORRIGIDO AQUI ▼▼▼
  void _navegarParaEditarGasto(int index, Transacao transacao) async {
    final transacaoEditada = await Navigator.push<Transacao>(
      context,
      MaterialPageRoute(
        builder: (context) => AddGastoPage(transacaoParaEditar: transacao), // CORRIGIDO
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
              // Pega a transação do serviço para passar adiante
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
        return Scaffold(
          appBar: AppBar(
            title: const Text('FitWallet'),
          ),
          drawer: _buildDrawer(),
          body: _buildBody(financeService),
          floatingActionButton: FloatingActionButton(
            onPressed: _navegarParaAddGasto,
            backgroundColor: const Color(0xFF059669),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  // --- Widgets do Corpo ---
  Widget _buildBody(FinanceService financeService) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildMetaCard(financeService),
        const SizedBox(height: 24),
        Text(
          'Gastos Recentes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF0B1220),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildTransacoesList(financeService),
      ],
    );
  }

  Widget _buildMetaCard(FinanceService financeService) {
    final totalGasto = financeService.transacoes.fold(0.0, (sum, item) => sum + item.valor);
    final meta = financeService.metaSemanal;
    final progresso = (meta > 0) ? totalGasto / meta : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // ▼▼▼ ERRO 2 CORRIGIDO AQUI ▼▼▼
          crossAxisAlignment: CrossAxisAlignment.start, // CORRIGIDO
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meta Semanal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B1220),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF475569)),
                  onPressed: _alterarMetaSemanal,
                  tooltip: 'Alterar Meta',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gasto: R\$ ${totalGasto.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, color: Color(0xFF475569)),
                ),
                Text(
                  'Meta: R\$ ${meta.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, color: Color(0xFF475569)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progresso.isNaN || progresso.isInfinite ? 0 : (progresso > 1.0 ? 1.0 : progresso),
              backgroundColor: const Color(0xFF475569).withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransacoesList(FinanceService financeService) {
    final transacoes = financeService.transacoes;

    if (transacoes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            'Nenhum gasto registrado ainda.\nClique no botão + para começar!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF475569)),
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
            leading: Icon(transacao.icone, color: const Color(0xFF059669)),
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

  // --- _buildDrawer ---
  Drawer _buildDrawer() {
    final theme = Theme.of(context);
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            accountName: const Text(
              'Usuário FitWallet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: const Text('seu.email@exemplo.com'),
            currentAccountPicture: Semantics(
              label: 'Foto do perfil',
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 36.0,
                    backgroundImage: _userPhotoPath != null
                        ? FileImage(File(_userPhotoPath!))
                        : null,
                    backgroundColor: Colors.white,
                    child: _userPhotoPath == null
                        ? Text(
                            'U',
                            style: TextStyle(
                              fontSize: 40.0,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      child: IconButton(
                        iconSize: 20,
                        icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                        onPressed: _onEditAvatarPressed,
                        tooltip: 'Alterar foto do perfil',
                      ),
                    ),
                  ),
                ],
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
            subtitle: const Text('Revoga consentimento da política'),
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