import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Imports da Nova Arquitetura
import '../features/transaction/domain/entities/transacao.dart';
import '../features/transaction/data/dtos/transacao_dto.dart';
import '../features/transaction/data/mappers/transacao_mapper.dart';

import '../features/goal/domain/entities/meta.dart';
import '../features/goal/data/dtos/meta_dto.dart';
import '../features/goal/data/mappers/meta_mapper.dart';

class FinanceService extends ChangeNotifier {
  late SharedPreferences _prefs;
  final _transacaoMapper = TransacaoMapper();
  final _metaMapper = MetaMapper();

  // Agora usamos a Entidade Meta, não apenas um double
  Meta _meta = Meta(id: 'meta_semanal', valor: 150.0, periodo: 'semanal');
  List<Transacao> _transacoes = [];

  // Getters para a UI acessar
  double get metaSemanal => _meta.valor; // Mantive o nome para facilitar na UI
  List<Transacao> get transacoes => _transacoes;

  FinanceService() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    
    // --- Carregar Meta ---
    final metaString = _prefs.getString('meta_atual');
    if (metaString != null) {
      try {
        final json = jsonDecode(metaString);
        final dto = MetaDTO.fromJson(json);
        _meta = _metaMapper.toEntity(dto);
      } catch (e) {
        debugPrint('Erro ao carregar meta: $e');
      }
    }

    // --- Carregar Transações ---
    final transacoesString = _prefs.getString('transacoes_v2'); // Mudei a chave para evitar conflito com dados antigos
    if (transacoesString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(transacoesString);
        _transacoes = jsonList.map((json) {
          final dto = TransacaoDTO.fromJson(json);
          return _transacaoMapper.toEntity(dto);
        }).toList();
      } catch (e) {
        debugPrint('Erro ao carregar transações: $e');
      }
    }
    
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    // --- Salvar Meta ---
    // Entidade -> DTO -> JSON
    final metaDto = _metaMapper.toDto(_meta);
    await _prefs.setString('meta_atual', jsonEncode(metaDto.toJson()));

    // --- Salvar Transações ---
    // Lista de Entidades -> Lista de DTOs -> JSON
    final transacoesDtos = _transacoes.map((t) => _transacaoMapper.toDto(t)).toList();
    final String transacoesString = jsonEncode(transacoesDtos.map((dto) => dto.toJson()).toList());
    await _prefs.setString('transacoes_v2', transacoesString);
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

  void atualizarMeta(double novoValor) {
    // Cria uma nova entidade Meta com o valor atualizado
    _meta = Meta(id: _meta.id, valor: novoValor, periodo: _meta.periodo);
    _saveToPrefs();
    notifyListeners();
  }
}