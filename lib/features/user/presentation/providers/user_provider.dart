import 'package:flutter/material.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/usecases/get_usuario_usecase.dart';
import '../../domain/usecases/update_usuario_foto_usecase.dart';
import '../../domain/usecases/remove_usuario_foto_usecase.dart';

class UserProvider extends ChangeNotifier {
  final GetUsuarioUseCase getUsuarioUseCase;
  final UpdateUsuarioFotoUseCase updateUsuarioFotoUseCase;
  final RemoveUsuarioFotoUseCase removeUsuarioFotoUseCase;

  Usuario? _usuario;
  bool _isLoading = false;

  UserProvider({
    required this.getUsuarioUseCase,
    required this.updateUsuarioFotoUseCase,
    required this.removeUsuarioFotoUseCase,
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

  Future<void> atualizarFoto(String path) async {
    await updateUsuarioFotoUseCase(path);
    await loadUsuario();
  }

  Future<void> removerFoto() async {
    await removeUsuarioFotoUseCase();
    await loadUsuario();
  }
}