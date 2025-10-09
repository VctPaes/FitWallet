import 'package:flutter/material.dart';
import '../models/refeicao.dart';

class MealService extends ChangeNotifier {
  final List<Refeicao> _cardapioExemplo = [
    Refeicao(nome: 'Aveia com Frutas', tipo: 'Café da Manhã', tags: {'Rápido', 'Saudável'}),
    Refeicao(nome: 'Ovos Mexidos com Pão Integral', tipo: 'Café da Manhã', tags: {'Rápido'}),
    Refeicao(nome: 'Salada de Grão de Bico com Frango', tipo: 'Almoço', tags: {'Saudável'}),
    Refeicao(nome: 'Macarrão com Pesto e Tomate', tipo: 'Almoço', tags: {'Rápido', 'Vegetariano'}),
    Refeicao(nome: 'Wrap de Frango e Salada', tipo: 'Almoço', tags: {'Rápido'}),
    Refeicao(nome: 'Sopa de Legumes', tipo: 'Jantar', tags: {'Saudável', 'Vegetariano'}),
    Refeicao(nome: 'Omelete com Queijo e Espinafre', tipo: 'Jantar', tags: {'Rápido'}),
    Refeicao(nome: 'Peixe Grelhado com Brócolis', tipo: 'Jantar', tags: {'Saudável'}),
  ];

  List<Refeicao> _planoSemanal = [];
  List<Refeicao> get planoSemanal => _planoSemanal;

  void gerarPlano(Set<String> preferencias) {
    List<Refeicao> refeicoesFiltradas = _cardapioExemplo;

    if (preferencias.isNotEmpty) {
      refeicoesFiltradas = _cardapioExemplo.where((refeicao) {
        return preferencias.every((tag) => refeicao.tags.contains(tag));
      }).toList();
    }

    refeicoesFiltradas.shuffle();
    _planoSemanal = refeicoesFiltradas.take(3).toList();

    notifyListeners();
  }
}