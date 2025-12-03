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
    // 1. Capturar referências ANTES de fechar o modal (pois o contexto será invalidado)
    final provider = context.read<TransactionProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // 2. Fecha o BottomSheet
    navigator.pop(); 

    // 3. Navega para a página de edição usando o navigator capturado
    final transacaoEditada = await navigator.push<Transacao>(
      MaterialPageRoute(
        builder: (context) => AddGastoPage(transacaoParaEditar: transacao),
      ),
    );

    // 4. Se houve retorno (salvou), atualiza usando o provider capturado
    if (transacaoEditada != null) {
      try {
        await provider.updateTransaction(transacaoEditada);
        
        messenger.showSnackBar(
          const SnackBar(content: Text('Transação atualizada com sucesso!')),
        );
      } catch (e) {
        messenger.showSnackBar(
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
    // 1. Capturar referências necessárias
    final provider = context.read<TransactionProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // 2. Fecha o BottomSheet atual
    navigator.pop();

    // 3. Abre o Dialog de confirmação
    // Nota: Usamos 'context' aqui apenas para criar o Dialog, o que é seguro pois
    // showDialog cria uma nova rota acima da atual.
    showDialog(
      context: context,
      barrierDismissible: false,
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
              
              // Usa o provider capturado no início do método
              try {
                await provider.deleteTransaction(transacao.id);
                
                messenger.showSnackBar(
                  const SnackBar(content: Text('Transação removida.')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  const SnackBar(
                      content: Text('Erro ao remover.'),
                      backgroundColor: Colors.red),
                );
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