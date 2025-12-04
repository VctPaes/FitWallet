import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/usecases/get_usuario_usecase.dart';
import '../../domain/usecases/update_usuario_foto_usecase.dart';
import '../../domain/usecases/remove_usuario_foto_usecase.dart';
import '../../domain/usecases/update_usuario_nome_usecase.dart';

class UserProvider extends ChangeNotifier {
  final GetUsuarioUseCase getUsuarioUseCase;
  final UpdateUsuarioFotoUseCase updateUsuarioFotoUseCase;
  final RemoveUsuarioFotoUseCase removeUsuarioFotoUseCase;
  final UpdateUsuarioNomeUseCase updateUsuarioNomeUseCase;

  Usuario? _usuario;
  bool _isLoading = false;

  UserProvider({
    required this.getUsuarioUseCase,
    required this.updateUsuarioFotoUseCase,
    required this.removeUsuarioFotoUseCase,
    required this.updateUsuarioNomeUseCase,
  });

  Usuario? get usuario => _usuario;
  bool get isLoading => _isLoading;

  Future<void> loadUsuario() async {
    _isLoading = true;
    notifyListeners();
    try {
      _usuario = await getUsuarioUseCase();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> atualizarFoto(Uint8List bytes, String extension) async {
    _isLoading = true; // Feedback visual é importante no upload
    notifyListeners();
    try {
      await updateUsuarioFotoUseCase(bytes, extension);
      await loadUsuario();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removerFoto() async {
    await removeUsuarioFotoUseCase();
    await loadUsuario();
  }

  Future<void> atualizarNome(String novoNome) async {
    await updateUsuarioNomeUseCase(novoNome);
    await loadUsuario();
  }
}