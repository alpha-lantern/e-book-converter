import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/book.dart';
import '../../providers/book_editor_state.dart';

class SeoSettingsTab extends ConsumerStatefulWidget {
  final Book initialBook;

  const SeoSettingsTab({
    super.key,
    required this.initialBook,
  });

  @override
  ConsumerState<SeoSettingsTab> createState() => _SeoSettingsTabState();
}

class _SeoSettingsTabState extends ConsumerState<SeoSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _authorController;
  late final TextEditingController _seoTitleController;
  late final TextEditingController _seoDescriptionController;
  late final TextEditingController _seoTagsController;

  @override
  void initState() {
    super.initState();
    final book = widget.initialBook;
    _authorController = TextEditingController(text: book.author ?? '');
    _seoTitleController = TextEditingController(text: book.seoTitle ?? '');
    _seoDescriptionController = TextEditingController(text: book.seoDescription ?? '');
    _seoTagsController = TextEditingController(text: book.seoTags.join(', '));

    _authorController.addListener(_onAuthorChanged);
    _seoTitleController.addListener(_onSeoTitleChanged);
    _seoDescriptionController.addListener(_onSeoDescriptionChanged);
    _seoTagsController.addListener(_onSeoTagsChanged);
  }

  @override
  void didUpdateWidget(covariant SeoSettingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialBook.id != oldWidget.initialBook.id) {
      final book = widget.initialBook;
      _authorController.text = book.author ?? '';
      _seoTitleController.text = book.seoTitle ?? '';
      _seoDescriptionController.text = book.seoDescription ?? '';
      _seoTagsController.text = book.seoTags.join(', ');
    }
  }

  void _onAuthorChanged() {
    ref.read(bookEditorNotifierProvider(widget.initialBook).notifier).updateAuthor(_authorController.text);
  }

  void _onSeoTitleChanged() {
    ref.read(bookEditorNotifierProvider(widget.initialBook).notifier).updateSeoTitle(_seoTitleController.text);
  }

  void _onSeoDescriptionChanged() {
    ref.read(bookEditorNotifierProvider(widget.initialBook).notifier).updateSeoDescription(_seoDescriptionController.text);
  }

  void _onSeoTagsChanged() {
    final tags = _seoTagsController.text.split(',');
    ref.read(bookEditorNotifierProvider(widget.initialBook).notifier).updateSeoTags(tags);
  }

  @override
  void dispose() {
    _authorController.removeListener(_onAuthorChanged);
    _seoTitleController.removeListener(_onSeoTitleChanged);
    _seoDescriptionController.removeListener(_onSeoDescriptionChanged);
    _seoTagsController.removeListener(_onSeoTagsChanged);

    _authorController.dispose();
    _seoTitleController.dispose();
    _seoDescriptionController.dispose();
    _seoTagsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(bookEditorNotifierProvider(widget.initialBook).notifier).save();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BookEditorState>(
      bookEditorNotifierProvider(widget.initialBook),
      (previous, next) {
        if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage!)),
          );
        } else if (next.successMessage != null && next.successMessage != previous?.successMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.successMessage!)),
          );
        }
      },
    );

    final editorState = ref.watch(bookEditorNotifierProvider(widget.initialBook));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _authorController,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Author',
                hintText: 'Enter author name',
                counterText: '',
              ),
              validator: (value) {
                if (value != null && value.trim().length > 100) {
                  return 'Author cannot exceed 100 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _seoTitleController,
              maxLength: 70,
              decoration: const InputDecoration(
                labelText: 'SEO Title',
                hintText: 'Enter SEO title',
                helperText: 'Recommended max 70 characters for search engines',
              ),
              validator: (value) {
                if (value != null && value.trim().length > 70) {
                  return 'SEO Title cannot exceed 70 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _seoDescriptionController,
              maxLength: 160,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'SEO Description',
                hintText: 'Enter SEO description',
                helperText: 'Recommended max 160 characters for search snippets',
              ),
              validator: (value) {
                if (value != null && value.trim().length > 160) {
                  return 'SEO Description cannot exceed 160 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _seoTagsController,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'SEO Tags',
                hintText: 'Enter tags separated by commas',
                helperText: 'Comma-separated keywords (max 20 tags)',
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (editorState.isSaving || !editorState.isDirty) ? null : _handleSave,
              child: editorState.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
