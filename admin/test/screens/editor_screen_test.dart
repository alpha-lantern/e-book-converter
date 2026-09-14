import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin/models/book.dart';
import 'package:admin/screens/editor_screen.dart';
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
      seoTags: const ['editorial', 'design', 'interactive'],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  });

  Widget createTestWidget({Book? book}) {
    return ProviderScope(
      overrides: [
        bookRepositoryProvider.overrideWithValue(fakeRepository),
      ],
      child: MaterialApp(
        home: EditorScreen(initialBook: book),
      ),
    );
  }

  testWidgets('Pre-populates SEO form fields correctly from initialBook', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(book: testBook));

    expect(find.text('Designing with Codex'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('Designing with Codex - The Complete Guide'), findsOneWidget);
    expect(find.text('Master digital publishing with Codex.'), findsOneWidget);
    expect(find.text('editorial, design, interactive'), findsOneWidget);
  });

  testWidgets('Saves updated SEO metadata and trims/parses tags successfully', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(book: testBook));

    // Clear and enter new Author
    final authorField = find.widgetWithText(TextFormField, 'Author');
    await tester.enterText(authorField, ' John Smith ');

    // Clear and enter new SEO Title
    final titleField = find.widgetWithText(TextFormField, 'SEO Title');
    await tester.enterText(titleField, ' New SEO Title ');

    // Clear and enter new SEO Description
    final descField = find.widgetWithText(TextFormField, 'SEO Description');
    await tester.enterText(descField, ' New description text. ');

    // Clear and enter new SEO Tags
    final tagsField = find.widgetWithText(TextFormField, 'SEO Tags');
    await tester.enterText(tagsField, '  flutter ,  codex, mobile , ');

    // Tap Save Settings button
    final saveButton = find.widgetWithText(ElevatedButton, 'Save Settings');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify repository received sanitized data
    expect(fakeRepository.updateCallCount, 1);
    expect(fakeRepository.lastUpdatedBook, isNotNull);
    expect(fakeRepository.lastUpdatedBook!.author, 'John Smith');
    expect(fakeRepository.lastUpdatedBook!.seoTitle, 'New SEO Title');
    expect(fakeRepository.lastUpdatedBook!.seoDescription, 'New description text.');
    expect(fakeRepository.lastUpdatedBook!.seoTags, ['flutter', 'codex', 'mobile']);

    // Verify success feedback
    expect(find.text('Settings saved successfully'), findsOneWidget);
  });

  testWidgets('Displays masked error SnackBar and logs error when updateBookMetadata throws', (WidgetTester tester) async {
    fakeRepository.shouldThrow = true;

    await tester.pumpWidget(createTestWidget(book: testBook));

    // Modify a field to make form dirty
    final authorField = find.widgetWithText(TextFormField, 'Author');
    await tester.enterText(authorField, 'Author Triggering Error');
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(ElevatedButton, 'Save Settings');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(fakeRepository.updateCallCount, 1);
    expect(find.text('Failed to save settings. Please try again or check debug logs.'), findsOneWidget);
  });

  testWidgets('Shows empty state message when opening editor without an active book', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(book: null));

    expect(find.text('No active book selected to edit.'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('Prompts discard confirmation when navigating back with unsaved changes', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditorScreen(initialBook: testBook),
                    ),
                  );
                },
                child: const Text('Open Editor'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open editor screen
    await tester.tap(find.text('Open Editor'));
    await tester.pumpAndSettle();

    // Modify a field to create dirty state
    final authorField = find.widgetWithText(TextFormField, 'Author');
    await tester.enterText(authorField, 'Changed Author Name');
    await tester.pumpAndSettle();

    // Attempt back navigation via the AppBar BackButton
    final backButton = find.byType(BackButton);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // Verify confirmation dialog is displayed
    expect(find.text('Unsaved Changes'), findsOneWidget);
    expect(find.text('Stay'), findsOneWidget);
    expect(find.text('Discard & Leave'), findsOneWidget);

    // Tap Stay
    await tester.tap(find.text('Stay'));
    await tester.pumpAndSettle();

    // Still in Editor
    expect(find.text('SEO Settings'), findsOneWidget);

    // Tap back again and confirm Discard & Leave
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Discard & Leave'));
    await tester.pumpAndSettle();

    // Now back on the main screen
    expect(find.text('Open Editor'), findsOneWidget);
  });
}
