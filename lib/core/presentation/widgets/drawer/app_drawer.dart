import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../features/user/presentation/providers/user_provider.dart';
import 'drawer_header_widget.dart';
import 'edit_name_dialog.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onEditAvatarPressed;

  const AppDrawer({
    super.key,
    required this.onEditAvatarPressed,
  });

  void _showEditNameDialog(BuildContext context) {
    // Recupera o nome atual antes de abrir o dialog
    final currentName = context.read<UserProvider>().usuario?.nome ?? '';
    
    showDialog(
      context: context,
      builder: (ctx) => EditNameDialog(currentName: currentName),
    );
  }

  void _showAboutDialog(BuildContext context) {
    Navigator.pop(context); // Fecha o Drawer
    showAboutDialog(
      context: context,
      applicationName: 'FitWallet',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Victor Paes',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // --- Cabeçalho Extraído ---
          DrawerHeaderWidget(
            onAvatarTap: onEditAvatarPressed,
          ),

          // --- Itens de Menu ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Editar Nome'),
                  onTap: () => _showEditNameDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: const Text('Gerenciar Foto'),
                  onTap: onEditAvatarPressed,
                ),
                
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
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}