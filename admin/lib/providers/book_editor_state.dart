import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/book.dart';
import '../services/book_repository.dart';
import '../services/debug_logger.dart';

part 'book_editor_state.g.dart';

class BookEditorState {
  final Book book;
  final Book draftBook;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const BookEditorState({
    required this.book,
    required this.draftBook,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get isDirty {
    return (draftBook.author ?? '').trim() != (book.author ?? '').trim() ||
        (draftBook.seoTitle ?? '').trim() != (book.seoTitle ?? '').trim() ||
        (draftBook.seoDescription ?? '').trim() != (book.seoDescription ?? '').trim() ||
        !_areListsEqual(draftBook.seoTags, book.seoTags);
  }

  static bool _areListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  BookEditorState copyWith({
    Book? book,
    Book? draftBook,
    bool? isSaving,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return BookEditorState(
      book: book ?? this.book,
      draftBook: draftBook ?? this.draftBook,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookEditorState &&
          runtimeType == other.runtimeType &&
          book.id == other.book.id &&
          book.updatedAt == other.book.updatedAt &&
          draftBook.author == other.draftBook.author &&
          draftBook.seoTitle == other.draftBook.seoTitle &&
          draftBook.seoDescription == other.draftBook.seoDescription &&
          _areListsEqual(draftBook.seoTags, other.draftBook.seoTags) &&
          isSaving == other.isSaving &&
          errorMessage == other.errorMessage &&
          successMessage == other.successMessage;

  @override
  int get hashCode => Object.hash(
        book.id,
        draftBook.author,
        draftBook.seoTitle,
        draftBook.seoDescription,
        Object.hashAll(draftBook.seoTags),
        isSaving,
        errorMessage,
        successMessage,
      );
}

@riverpod
class BookEditorNotifier extends _$BookEditorNotifier {
  @override
  BookEditorState build(Book initialBook) {
    return BookEditorState(
      book: initialBook,
      draftBook: initialBook,
    );
  }

  void updateAuthor(String author) {
    final trimmed = author.trim();
    state = state.copyWith(
      draftBook: state.draftBook.copyWith(
        author: trimmed.isEmpty ? null : trimmed,
      ),
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void updateSeoTitle(String title) {
    final trimmed = title.trim();
    state = state.copyWith(
      draftBook: state.draftBook.copyWith(
        seoTitle: trimmed.isEmpty ? null : trimmed,
      ),
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void updateSeoDescription(String description) {
    final trimmed = description.trim();
    state = state.copyWith(
      draftBook: state.draftBook.copyWith(
        seoDescription: trimmed.isEmpty ? null : trimmed,
      ),
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void updateSeoTags(List<String> tags) {
    final sanitizedTags = tags
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .take(20)
        .toList();

    state = state.copyWith(
      draftBook: state.draftBook.copyWith(
        seoTags: sanitizedTags,
      ),
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void resetDraft() {
    state = state.copyWith(
      draftBook: state.book,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  Future<bool> save() async {
    if (state.isSaving) return false;

    state = state.copyWith(
      isSaving: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final repository = ref.read(bookRepositoryProvider);
      final updatedBook = await repository.updateBookMetadata(state.draftBook);
      ref.invalidate(bookListProvider);

      state = state.copyWith(
        book: updatedBook,
        draftBook: updatedBook,
        isSaving: false,
        successMessage: 'Settings saved successfully',
      );
      return true;
    } catch (e, st) {
      ref.read(debugLoggerProvider.notifier).logError(
            'Failed to save book settings for ${state.book.id}',
            error: e,
            stackTrace: st,
          );
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save settings. Please try again or check debug logs.',
      );
      return false;
    }
  }
}
