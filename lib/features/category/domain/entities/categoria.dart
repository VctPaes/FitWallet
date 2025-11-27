class Categoria {
  final String id;
  final String nome;
  final int iconePontoDeCodigo; 
  final int corHex; 
  final String iconKey;

  Categoria({
    required this.id,
    required this.nome,
    required this.iconePontoDeCodigo,
    required this.corHex,
    required this.iconKey,
  });

  @override
  String toString() {
    return 'Categoria(id: $id, nome: $nome)';
  }
}