import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/transacao.dart';

class CategoriaView {
  final String id;
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

  void _salvarGasto() {
    if (_formKey.currentState!.validate()) {
      
      final String id = isEditing 
          ? widget.transacaoParaEditar!.id 
          : DateTime.now().millisecondsSinceEpoch.toString();

      final gastoProcessado = Transacao(
        id: id,
        titulo: _tituloController.text,
        valor: double.parse(_valorController.text.replaceAll(',', '.')),
        data: widget.transacaoParaEditar?.data ?? DateTime.now(),
        categoriaId: _categoriaSelecionada!.id,
      );
      
      Navigator.of(context).pop(gastoProcessado);
    }
  }

  InputDecoration _buildInputDecoration(BuildContext context, String label, {String? hint, String? prefix}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      filled: true,
      fillColor: isDark ? theme.colorScheme.surfaceVariant.withOpacity(0.3) : Colors.grey.shade100,
      labelStyle: TextStyle(
        color: isDark ? theme.colorScheme.onSurface.withOpacity(0.7) : Colors.grey.shade700,
      ),
      hintStyle: TextStyle(
        color: isDark ? theme.colorScheme.onSurface.withOpacity(0.4) : Colors.grey.shade400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Gasto' : 'Adicionar Gasto'),
        backgroundColor: theme.colorScheme.primary, 
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
                decoration: _buildInputDecoration(context, 'Descrição', hint: 'Ex: Almoço'),
                textCapitalization: TextCapitalization.sentences,
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
                decoration: _buildInputDecoration(context, 'Valor (R\$)', hint: '25,50', prefix: 'R\$ '),
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
                decoration: _buildInputDecoration(context, 'Categoria'),
                dropdownColor: theme.cardColor,
                items: _categorias.map((CategoriaView categoria) {
                  return DropdownMenuItem<CategoriaView>(
                    value: categoria,
                    child: Row(
                      children: [
                        Icon(categoria.icone, color: theme.colorScheme.primary),
                        const SizedBox(width: 10),
                        Text(
                          categoria.nome,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface
                          ),
                        ),
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
                    backgroundColor: theme.colorScheme.primary,
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