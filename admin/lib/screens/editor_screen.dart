import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';
import '../core/config.dart';
import '../models/book.dart';
import '../providers/book_editor_state.dart';
import '../services/book_repository.dart';
import '../utils/web_helpers/web_helpers.dart';
import '../widgets/editor/seo_settings_tab.dart';
import '../widgets/pdf_panel.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final Book? initialBook;

  const EditorScreen({super.key, this.initialBook});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late final MultiSplitViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MultiSplitViewController(
      areas: [
        Area(flex: 0.6),
        Area(flex: 0.4),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openReaderPreview(String bookId) {
    final url = '${AppConfig.readerBaseUrl}/preview?book_id=$bookId';
    WebHelpers.openUrl(url);
  }

  Future<void> _downloadPwaManifest(BuildContext context, Book book) async {
    if (book.status != BookStatus.completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book is still processing. Please wait for parsing to complete before downloading.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final repo = ref.read(bookRepositoryProvider);
      final manifest = await repo.getManifest(book.id);

      if (manifest == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Manifest not found in database for this book.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final jsonString = const JsonEncoder.withIndent('  ').convert(manifest);
      WebHelpers.downloadJson('${book.slug}_manifest.json', jsonString);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded ${book.slug}_manifest.json. Run "./dev export" to package into standalone PWA zip.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download manifest: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool?> _showDiscardConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes in SEO Settings. Are you sure you want to discard them and leave?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard & Leave'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.initialBook ?? (ModalRoute.of(context)?.settings.arguments as Book?);

    if (book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editor')),
        body: const Center(
          child: Text('No active book selected to edit.'),
        ),
      );
    }

    final editorState = ref.watch(bookEditorNotifierProvider(book));

    return PopScope(
      canPop: !editorState.isDirty || editorState.isSaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _showDiscardConfirmationDialog();
        if (shouldLeave == true && context.mounted) {
          ref.read(bookEditorNotifierProvider(book).notifier).resetDraft();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(editorState.book.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.chrome_reader_mode_outlined),
              tooltip: 'Preview in Reader',
              onPressed: () => _openReaderPreview(editorState.book.id),
            ),
            IconButton(
              icon: const Icon(Icons.download_for_offline_outlined),
              tooltip: 'Download PWA Manifest',
              onPressed: () => _downloadPwaManifest(context, editorState.book),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: MultiSplitViewTheme(
          data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.background(
              color: Colors.grey[400]!,
              highlightedColor: Colors.blue,
            ),
          ),
          child: MultiSplitView(
            controller: _controller,
            builder: (context, area) {
              if (area.index == 0) {
                return PdfPanel(pdfUrl: editorState.book.originalPdfUrl);
              } else {
                return _buildSettingsSidebar(book);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSidebar(Book book) {
    return DefaultTabController(
      length: 1,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'SEO Settings'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                SeoSettingsTab(initialBook: book),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

