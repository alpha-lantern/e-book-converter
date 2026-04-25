import 'package:flutter/material.dart';
import '../models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(book.title),
        subtitle: Text(
            'Status: ${book.status.name[0].toUpperCase()}${book.status.name.substring(1)}'),
        trailing: _getStatusIcon(book.status),
      ),
    );
  }

  Widget _getStatusIcon(BookStatus status) {
    switch (status) {
      case BookStatus.processing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case BookStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case BookStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
    }
  }
}
