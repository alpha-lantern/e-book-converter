import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import '../models/book.dart';
import '../widgets/pdf_panel.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
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

  @override
  Widget build(BuildContext context) {
    final book = ModalRoute.of(context)!.settings.arguments as Book?;

    return Scaffold(
      appBar: AppBar(
        title: Text(book?.title ?? 'Editor'),
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
              return _buildMainContent(book);
            } else {
              return _buildSettingsSidebar();
            }
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(Book? book) {
    return PdfPanel(pdfUrl: book?.originalPdfUrl);
  }

  Widget _buildSettingsSidebar() {
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
                _buildSeoSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeoSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Author',
              hintText: 'Enter author name',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'SEO Title',
              hintText: 'Enter SEO title',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'SEO Description',
              hintText: 'Enter SEO description',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'SEO Tags',
              hintText: 'Enter tags separated by commas',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement save logic
            },
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}
