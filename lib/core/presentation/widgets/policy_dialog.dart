import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

// --- WIDGET DO DIÁLOGO REUTILIZÁVEL ---
class PolicyDialog extends StatefulWidget {
  final String title;
  final String content;
  const PolicyDialog({super.key, required this.title, required this.content});

  @override
  State<PolicyDialog> createState() => _PolicyDialogState();
}

class _PolicyDialogState extends State<PolicyDialog> {
  bool _reachedEnd = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollExtent();
    });
  }

  void _checkScrollExtent() {
    if (!mounted) return;
    
    if (_scrollController.hasClients && _scrollController.position.maxScrollExtent <= 0) {
      setState(() {
        _reachedEnd = true;
      });
    }
  }

  void _onScroll() {
    if (!_reachedEnd && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      setState(() {
        _reachedEnd = true;
      });
    }
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onTapLink(String text, String? href, String title) async {
    if (href != null) {
      final Uri url = Uri.parse(href);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Não foi possível abrir o link: $href')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: screenSize.width * 0.9,
        child: Scrollbar(
          thumbVisibility: true,
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: MarkdownBody(
              data: widget.content,
              onTapLink: _onTapLink,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                h1: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                h2: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _reachedEnd
              ? () => Navigator.of(context).pop(true)
              : null,
          child: const Text('Li e Concordo'),
        ),
      ],
    );
  }
}