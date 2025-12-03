import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/user/presentation/providers/user_provider.dart';

class EditNameDialog extends StatefulWidget {
  final String currentName;

  const EditNameDialog({super.key, required this.currentName});

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final novoNome = _controller.text.trim();
    if (novoNome.isNotEmpty) {
      await context.read<UserProvider>().atualizarNome(novoNome);
      
      if (mounted) {
        Navigator.of(context).pop(); // Fecha o Dialog
        // O Drawer permanece aberto, mas atualizado
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nome atualizado com sucesso!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Nome'),
      content: TextField(
        controller: _controller,
        textCapitalization: TextCapitalization.words,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Digite seu nome',
          labelText: 'Nome',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}