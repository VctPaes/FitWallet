import 'package:flutter/material.dart';
import '../../domain/entities/meta.dart';
import '../../domain/usecases/get_meta_usecase.dart';
import '../../domain/usecases/update_meta_usecase.dart';

class GoalProvider extends ChangeNotifier {
  final GetMetaUseCase getMetaUseCase;
  final UpdateMetaUseCase updateMetaUseCase;

  Meta? _meta;
  bool _isLoading = false;

  GoalProvider({
    required this.getMetaUseCase,
    required this.updateMetaUseCase,
  });

  Meta? get meta => _meta;
  bool get isLoading => _isLoading;

  Future<void> loadMeta() async {
    _isLoading = true;
    notifyListeners();
    try {
      _meta = await getMetaUseCase();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMeta(double valor) async {
    await updateMetaUseCase(valor);
    await loadMeta(); // Recarrega
  }
}