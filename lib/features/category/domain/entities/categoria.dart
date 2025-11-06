class Categoria {
  final String id;
  final String nome;
  final int iconePontoDeCodigo; 
  final int corHex; 

  Categoria({
    required this.id,
    required this.nome,
    required this.iconePontoDeCodigo,
    required this.corHex,
  });

  @override
  String toString() {
    return 'Categoria(id: $id, nome: $nome)';
  }
}