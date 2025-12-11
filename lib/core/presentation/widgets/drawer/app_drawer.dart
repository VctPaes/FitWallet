import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../features/user/presentation/providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import 'drawer_header_widget.dart';
import 'edit_name_dialog.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onEditAvatarPressed;

  const AppDrawer({
    super.key,
    required this.onEditAvatarPressed,
  });

  void _showEditNameDialog(BuildContext context) {
    final currentName = context.read<UserProvider>().usuario?.nome ?? '';
    
    showDialog(
      context: context,
      builder: (ctx) => EditNameDialog(currentName: currentName),
    );
  }

  void _showAboutDialog(BuildContext context) {
    Navigator.pop(context);
    showAboutDialog(
      context: context,
      applicationName: 'FitWallet',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Victor Paes',
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = themeProvider.themeMode == ThemeMode.dark ||(themeProvider.themeMode == ThemeMode.system && brightness == Brightness.dark);
    return Drawer(
      child: Column(
        children: [
          DrawerHeaderWidget(
            onAvatarTap: onEditAvatarPressed,
          ),

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

                SwitchListTile(
                  secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                  title: const Text('Tema Escuro'),
                  subtitle: Text(
                    themeProvider.isSystemMode 
                      ? 'Automático (Sistema)' 
                      : (isDark ? 'Ativado' : 'Desativado')
                  ),
                  value: isDark,
                  onChanged: (val) {
                    final newMode = val ? ThemeMode.dark : ThemeMode.light;
                    context.read<ThemeProvider>().updateThemeMode(newMode);
                  },
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