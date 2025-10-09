import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transacao.dart'; // <-- MUDANÇA AQUI

class FinanceService extends ChangeNotifier {
  late SharedPreferences _prefs;

  double _metaSemanal = 150.0;
  List<Transacao> _transacoes = [];

  double get metaSemanal => _metaSemanal;
  List<Transacao> get transacoes => _transacoes;

  FinanceService() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    
    _metaSemanal = _prefs.getDouble('metaSemanal') ?? 150.0;

    final transacoesString = _prefs.getString('transacoes');
    if (transacoesString != null) {
      final List<dynamic> transacoesJson = jsonDecode(transacoesString);
      _transacoes = transacoesJson.map((json) => Transacao.fromJson(json)).toList();
    }
    
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    await _prefs.setDouble('metaSemanal', _metaSemanal);
    final String transacoesString = jsonEncode(_transacoes.map((t) => t.toJson()).toList());
    await _prefs.setString('transacoes', transacoesString);
  }

  void adicionarTransacao(Transacao transacao) {
    _transacoes.insert(0, transacao);
    _saveToPrefs();
    notifyListeners();
  }

  void atualizarTransacao(int index, Transacao transacao) {
    _transacoes[index] = transacao;
    _saveToPrefs();
    notifyListeners();
  }

  void removerTransacao(int index) {
    _transacoes.removeAt(index);
    _saveToPrefs();
    notifyListeners();
  }

  void atualizarMeta(double novaMeta) {
    _metaSemanal = novaMeta;
    _saveToPrefs();
    notifyListeners();
  }
}