import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/book_repository.dart';
import 'book_card.dart';

class BookListView extends ConsumerWidget {
  const BookListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookListAsync = ref.watch(bookListProvider);

    return bookListAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return const Center(
            child: Text('No books found. Upload one to get started!'),
          );
        }
        return ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return BookCard(book: book);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading books: $error'),
      ),
    );
  }
}
