import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../features/transaction/domain/entities/transacao.dart'; // Importe a nova entidade

// Helper visual para as categorias no Dropdown
class CategoriaView {
  final String id; // ID que será salvo na Entidade
  final String nome;
  final IconData icone;
  
  CategoriaView({
    required this.id, 
    required this.nome, 
    required this.icone
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoriaView &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class AddGastoPage extends StatefulWidget {
  final Transacao? transacaoParaEditar;

  const AddGastoPage({super.key, this.transacaoParaEditar});

  @override
  State<AddGastoPage> createState() => _AddGastoPageState();
}

class _AddGastoPageState extends State<AddGastoPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _valorController = TextEditingController();

  // Lista de categorias com IDs fixos para mapeamento
  final List<CategoriaView> _categorias = [
    CategoriaView(id: 'cat_alimentacao', nome: 'Alimentação', icone: Icons.fastfood),
    CategoriaView(id: 'cat_transporte', nome: 'Transporte', icone: Icons.directions_bus),
    CategoriaView(id: 'cat_lazer', nome: 'Lazer', icone: Icons.sports_esports),
    CategoriaView(id: 'cat_moradia', nome: 'Moradia', icone: Icons.home),
    CategoriaView(id: 'cat_outros', nome: 'Outros', icone: Icons.more_horiz),
  ];
  
  CategoriaView? _categoriaSelecionada;

  bool get isEditing => widget.transacaoParaEditar != null;

  @override
  void initState() {
    super.initState();
    
    if (isEditing) {
      final gasto = widget.transacaoParaEditar!;
      _tituloController.text = gasto.titulo;
      _valorController.text = gasto.valor.toStringAsFixed(2).replaceAll('.', ',');
      
      // Encontra a categoria correta baseada no ID salvo
      _categoriaSelecionada = _categorias.firstWhere(
        (cat) => cat.id == gasto.categoriaId,
        orElse: () => _categorias.last,
      );
    } else {
      _categoriaSelecionada = _categorias.first;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  // --- Métodos de Ação ---

  void _salvarGasto() {
    if (_formKey.currentState!.validate()) {
      
      // Se for edição, mantém o ID. Se for novo, gera um ID baseado no tempo.
      final String id = isEditing 
          ? widget.transacaoParaEditar!.id 
          : DateTime.now().millisecondsSinceEpoch.toString();

      final gastoProcessado = Transacao(
        id: id,
        titulo: _tituloController.text,
        valor: double.parse(_valorController.text.replaceAll(',', '.')),
        data: widget.transacaoParaEditar?.data ?? DateTime.now(),
        categoriaId: _categoriaSelecionada!.id, // Salva o ID da categoria
      );
      
      Navigator.of(context).pop(gastoProcessado);
    }
  }

  // --- Widgets de Construção ---

  InputDecoration _buildInputDecoration(String label, {String? hint, String? prefix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Gasto' : 'Adicionar Gasto'),
        backgroundColor: theme.colorScheme.secondary, // Navy
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: _buildInputDecoration('Descrição', hint: 'Ex: Almoço'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                decoration: _buildInputDecoration('Valor (R\$)', hint: '25,50', prefix: 'R\$ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um valor.';
                  }
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return 'Por favor, insira um valor numérico válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CategoriaView>(
                value: _categoriaSelecionada,
                decoration: _buildInputDecoration('Categoria'),
                items: _categorias.map((CategoriaView categoria) {
                  return DropdownMenuItem<CategoriaView>(
                    value: categoria,
                    child: Row(
                      children: [
                        Icon(categoria.icone, color: theme.colorScheme.primary), // Emerald
                        const SizedBox(width: 10),
                        Text(categoria.nome),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (CategoriaView? novoValor) {
                  setState(() {
                    _categoriaSelecionada = novoValor;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione uma categoria.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvarGasto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary, // Emerald
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}