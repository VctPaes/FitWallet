import 'package:flutter/material.dart';

class Transacao {
  final String titulo;
  final double valor;
  final DateTime data;
  final IconData icone;

  Transacao({
    required this.titulo,
    required this.valor,
    required this.data,
    required this.icone,
  });

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'valor': valor,
      'data': data.toIso8601String(),
      'icone_code': icone.codePoint,
      'icone_family': icone.fontFamily,
    };
  }

  factory Transacao.fromJson(Map<String, dynamic> json) {
    return Transacao(
      titulo: json['titulo'],
      valor: json['valor'],
      data: DateTime.parse(json['data']),
      icone: IconData(
        json['icone_code'],
        fontFamily: json['icone_family'],
      ),
    );
  }
}