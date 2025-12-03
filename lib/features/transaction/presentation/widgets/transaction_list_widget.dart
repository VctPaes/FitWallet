import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../domain/entities/transacao.dart';
import '../providers/transaction_provider.dart';

class TransactionListWidget extends StatelessWidget {
  final Function(Transacao) onTransactionTap;

  const TransactionListWidget({
    super.key,
    required this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    // Consumindo o Provider
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        // 1. Estado de Loading
        if (provider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 2. Estado de Erro
        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  TextButton(
                    onPressed: () => provider.loadTransactions(),
                    child: const Text('Tentar novamente'),
                  )
                ],
              ),
            ),
          );
        }

        // 3. Estado Vazio
        if (provider.transacoes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Column(
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 60,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum gasto registrado',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8),
                        ),
                  ),
                  Text(
                    'Toque no + para adicionar.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        // 4. Estado de Sucesso (Lista)
        return ListView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(), // A rolagem fica por conta da página pai
          itemCount: provider.transacoes.length,
          itemBuilder: (context, index) {
            final transacao = provider.transacoes[index];
            return _buildTransactionItem(context, transacao);
          },
        );
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transacao transacao) {
    final theme = Theme.of(context);

    // Busca dados da categoria para o ícone e cor
    final categoryProvider = context.read<CategoryProvider>();
    final categoria = categoryProvider.getCategoriaById(transacao.categoriaId);

    final iconData = categoria != null
        ? CategoryProvider.getIconFromKey(categoria.iconKey)
        : Icons.help_outline;

    final iconColor =
        categoria != null ? Color(categoria.corHex) : theme.colorScheme.primary;

    // Formatação da Data (dd/MM)
    final dateString =
        '${transacao.data.day.toString().padLeft(2, '0')}/${transacao.data.month.toString().padLeft(2, '0')}/${transacao.data.year}';

    return Dismissible(
      key: Key(transacao.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        // Retorna true para confirmar a remoção, false para cancelar
        return await showDialog(
          context: context,
          barrierDismissible: false, // Obriga o usuário a escolher uma ação
          builder: (ctx) => AlertDialog(
            title: const Text('Remover Transação?'),
            content: Text('Deseja remover "${transacao.titulo}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false), // Retorna false
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true), // Retorna true
                child:
                    const Text('Remover', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<TransactionProvider>().deleteTransaction(transacao.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transação removida.')),
        );
      },
      child: Card(
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(iconData, color: iconColor),
          ),
          title: Text(
            transacao.titulo,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            dateString,
            style:
                TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'R\$ ${transacao.valor.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.redAccent, // Destaque para o valor (gasto)
                ),
              ),
              const SizedBox(width: 8),
              // Botão de opções (mantendo a funcionalidade original)
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                onPressed: () => onTransactionTap(transacao),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
