import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/user/presentation/providers/user_provider.dart';

class DrawerHeaderWidget extends StatelessWidget {
  final VoidCallback onAvatarTap;

  const DrawerHeaderWidget({super.key, required this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final usuario = userProvider.usuario;
        final userPhotoPath = usuario?.fotoPath;
        final userName = usuario?.nome ?? 'Visitante';

        ImageProvider? imageProvider;
        if (userPhotoPath != null && userPhotoPath.isNotEmpty) {
          if (userPhotoPath.startsWith('http')) {
            imageProvider = NetworkImage(userPhotoPath);
          } else {
            imageProvider = FileImage(File(userPhotoPath));
          }
        }

        return Container(
          height: 200,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary, 
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 36.0,
                  backgroundImage: imageProvider,
                  backgroundColor: Colors.white,
                  child: userPhotoPath == null
                      ? Text(
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
        );
      },
    );
  }
}