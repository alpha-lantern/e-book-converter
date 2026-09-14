import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin/models/book.dart';
import 'package:admin/providers/book_editor_state.dart';
import 'package:admin/services/book_repository.dart';
import 'dart:typed_data';

class FakeBookRepository implements BookRepository {
  Book? lastUpdatedBook;
  bool shouldThrow = false;
  int updateCallCount = 0;

  @override
  Future<List<Book>> getBooks() async => [];

  @override
  Future<Book> createBook(String fileName, Uint8List fileBytes) async {
    throw UnimplementedError();
  }

  @override
  Future<Book> updateBookMetadata(Book book) async {
    updateCallCount++;
    if (shouldThrow) {
      throw Exception('Database update failed');
    }
    lastUpdatedBook = book;
    return book;
  }

  @override
  Future<Map<String, dynamic>?> getManifest(String bookId) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeBookRepository fakeRepository;
  late Book testBook;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fakeRepository = FakeBookRepository();
    testBook = Book(
      id: 'book-123',
      ownerId: 'owner-456',
      title: 'Designing with Codex',
      slug: 'designing-with-codex',
      description: 'A comprehensive guide to digital editorial design.',
      originalPdfUrl: null,
      status: BookStatus.completed,
      isPublished: true,
      author: 'Jane Doe',
      seoTitle: 'Designing with Codex - The Complete Guide',
      seoDescription: 'Master digital publishing with Codex.',
      seoTags: const ['editorial', 'design'],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        bookRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('BookEditorNotifier initializes with clean state and book data', () {
    final container = createContainer();
    final state = container.read(bookEditorNotifierProvider(testBook));

    expect(state.book, testBook);
    expect(state.draftBook, testBook);
    expect(state.isDirty, false);
    expect(state.isSaving, false);
    expect(state.errorMessage, isNull);
    expect(state.successMessage, isNull);
  });

  test('BookEditorNotifier marks state as dirty on metadata mutations', () {
    final container = createContainer();
    final notifier = container.read(bookEditorNotifierProvider(testBook).notifier);

    notifier.updateAuthor('Updated Author');
    var state = container.read(bookEditorNotifierProvider(testBook));
    expect(state.isDirty, true);
    expect(state.draftBook.author, 'Updated Author');

    notifier.resetDraft();
    state = container.read(bookEditorNotifierProvider(testBook));
    expect(state.isDirty, false);
    expect(state.draftBook.author, 'Jane Doe');
  });

  test('BookEditorNotifier saves successfully and clears dirty state', () async {
    final container = createContainer();
    final notifier = container.read(bookEditorNotifierProvider(testBook).notifier);

    notifier.updateSeoTitle('New SEO Title');
    notifier.updateSeoTags(['flutter', 'codex']);

    final success = await notifier.save();
    expect(success, true);

    final state = container.read(bookEditorNotifierProvider(testBook));
    expect(state.isDirty, false);
    expect(state.isSaving, false);
    expect(state.book.seoTitle, 'New SEO Title');
    expect(state.book.seoTags, ['flutter', 'codex']);
    expect(state.successMessage, 'Settings saved successfully');
    expect(state.errorMessage, isNull);
    expect(fakeRepository.updateCallCount, 1);
  });

  test('BookEditorNotifier handles repository failure gracefully', () async {
    fakeRepository.shouldThrow = true;
    final container = createContainer();
    final notifier = container.read(bookEditorNotifierProvider(testBook).notifier);

    notifier.updateAuthor('Failed Author');
    final success = await notifier.save();
    expect(success, false);

    final state = container.read(bookEditorNotifierProvider(testBook));
    expect(state.isDirty, true);
    expect(state.isSaving, false);
    expect(state.errorMessage, 'Failed to save settings. Please try again or check debug logs.');
    expect(state.successMessage, isNull);
  });
}
