import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';
import '../models/book.dart';
import '../providers/book_editor_state.dart';
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

