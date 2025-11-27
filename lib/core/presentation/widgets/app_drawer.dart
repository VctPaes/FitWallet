import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import do Provider de Usuário
import '../../../features/user/presentation/providers/user_provider.dart';

class AppDrawer extends StatelessWidget {
  // Mantemos apenas o callback para abrir a edição de foto (que é uma ação externa na Home)
  final VoidCallback onEditAvatarPressed;

  const AppDrawer({
    super.key,
    required this.onEditAvatarPressed,
  });

  // --- Método Auxiliar: Mostra o Dialog de Edição ---
  void _showEditNameDialog(BuildContext context, String currentName) {
    final TextEditingController controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Editar Nome'),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Digite seu nome',
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final novoNome = controller.text.trim();
                if (novoNome.isNotEmpty) {
                  // Chama o provider para atualizar o nome
                  // O context.read funciona aqui porque estamos dentro de um callback
                  await context.read<UserProvider>().atualizarNome(novoNome);
                  
                  if (context.mounted) {
                    Navigator.of(ctx).pop(); // Fecha o Dialog
                    Navigator.of(context).pop(); // Fecha o Drawer
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nome atualizado com sucesso!')),
                    );
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Escuta as mudanças do usuário globalmente para atualizar o Drawer automaticamente
    final userProvider = context.watch<UserProvider>();
    final usuario = userProvider.usuario;
    final userPhotoPath = usuario?.fotoPath;
    final userName = usuario?.nome ?? 'Visitante';

    return Drawer(
      child: Column(
        children: [
          // --- Cabeçalho do Drawer ---
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary, // Navy
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onEditAvatarPressed,
                  child: CircleAvatar(
                    radius: 36.0,
                    backgroundImage: userPhotoPath != null
                        ? FileImage(File(userPhotoPath))
                        : null,
                    backgroundColor: Colors.white,
                    child: userPhotoPath == null
                        ? Text(
                            // Pega a primeira letra do nome ou 'U'
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontSize: 40.0,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Toque na foto para gerenciar',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // --- Itens de Menu ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Editar Nome'),
                  onTap: () {
                    // Chama o nosso novo método passando o nome atual
                    _showEditNameDialog(context, userName);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: const Text('Gerenciar Foto'),
                  onTap: onEditAvatarPressed,
                ),
                
                // --- Divisor ---
                const Divider(height: 1, indent: 16, endIndent: 16),
                
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Configurações'),
                  onTap: () {
                    Navigator.pop(context); 
                    Navigator.of(context).pushNamed('/settings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Sobre'),
                  onTap: () {
                    Navigator.pop(context);
                    showAboutDialog(
                      context: context,
                      applicationName: 'FitWallet',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2025 Victor Paes',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}