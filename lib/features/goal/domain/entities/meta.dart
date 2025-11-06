class Meta {
  final String id;
  final double valor;
  final String periodo;

  Meta({
    required this.id,
    required this.valor,
    required this.periodo,
  }) {
    if (valor <= 0) {
      throw ArgumentError('Valor da meta deve ser positivo: $valor');
    }
  }

  @override
  String toString() {
    return 'Meta(id: $id, valor: $valor, periodo: $periodo)';
  }
}