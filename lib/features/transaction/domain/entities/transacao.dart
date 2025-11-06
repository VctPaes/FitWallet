class Transacao {
  final String id;
  final String titulo;
  final double valor;
  final DateTime data;
  final String categoriaId;

  Transacao({
    required this.id,
    required this.titulo,
    required this.valor,
    required this.data,
    required this.categoriaId,
  }) {
    if (valor <= 0) {
      throw ArgumentError('Valor da transação deve ser positivo: $valor');
    }
  }

  @override
  String toString() {
    return 'Transacao(id: $id, titulo: $titulo, valor: $valor, data: $data, categoriaId: $categoriaId)';
  }
}