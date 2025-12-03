import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/transacao.dart';
import '../pages/add_gasto_page.dart';
import '../providers/transaction_provider.dart';

class TransactionActionsSheet extends StatelessWidget {
  final Transacao transacao;

  const TransactionActionsSheet({
    super.key,
    required this.transacao,
  });

  // --- Lógica de Edição ---
  void _editar(BuildContext context) async {
    // 1. Fecha o BottomSheet primeiro
    Navigator.pop(context);

    // 2. Navega para a página de edição
    final transacaoEditada = await Navigator.push<Transacao>(
      context,
      MaterialPageRoute(
        builder: (context) => AddGastoPage(transacaoParaEditar: transacao),
      ),
    );

    // 3. Se houve retorno (salvou), atualiza o provider
    if (transacaoEditada != null && context.mounted) {
      try {
        await context
            .read<TransactionProvider>()
            .updateTransaction(transacaoEditada);
            
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transação atualizada com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- Lógica de Remoção ---
  void _confirmarRemocao(BuildContext context) {
    // 1. Fecha o BottomSheet
    Navigator.pop(context);

    // 2. Abre o Dialog de confirmação
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Transação?'),
        content: Text('Deseja realmente remover "${transacao.titulo}"?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Fecha o Dialog
              
              // Chama o provider para deletar
              try {
                await context
                    .read<TransactionProvider>()
                    .deleteTransaction(transacao.id);
                    
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transação removida.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Erro ao remover.'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Ações para "${transacao.titulo}"',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: Color(0xFF059669)), // Emerald
            title: const Text('Editar'),
            onTap: () => _editar(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Remover'),
            onTap: () => _confirmarRemocao(context),
          ),
          const SizedBox(height: 8), // Espaçamento extra no fundo
        ],
      ),
    );
  }
}