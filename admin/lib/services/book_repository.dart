import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/book.dart';

part 'book_repository.g.dart';

class BookRepository {
  final SupabaseClient _supabase;

  BookRepository(this._supabase);

  Future<List<Book>> getBooks() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('books')
        .select()
        .eq('owner_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Book.fromJson(json)).toList();
  }

  Future<Book> createBook(String filePath) async {
    final file = File(filePath);
    final fileName = filePath.split('/').last;
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final baseName = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;

    final storagePath = '${user.id}/$fileName';

    // 1. Upload PDF to storage with error handling
    try {
      await _supabase.storage.from('raw_pdfs').upload(
            storagePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
    } catch (e) {
      throw Exception('Failed to upload PDF to storage: $e');
    }

    final publicUrl = _supabase.storage.from('raw_pdfs').getPublicUrl(storagePath);

    // 2. Create database record
    final response = await _supabase.from('books').insert({
      'owner_id': user.id,
      'title': baseName,
      'slug': '${baseName.toLowerCase().replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch}',
      'original_pdf_url': publicUrl,
      'status': BookStatus.processing.name,
    }).select().single();

    return Book.fromJson(response);
  }

  Future<Book> updateBookMetadata(Book book) async {
    final response = await _supabase.from('books').update({
      'author': book.author,
      'seo_title': book.seoTitle,
      'seo_description': book.seoDescription,
      'seo_tags': book.seoTags,
    }).eq('id', book.id).select().single();

    return Book.fromJson(response);
  }
}

@riverpod
BookRepository bookRepository(BookRepositoryRef ref) {
  return BookRepository(Supabase.instance.client);
}

@riverpod
Future<List<Book>> bookList(BookListRef ref) async {
  return ref.watch(bookRepositoryProvider).getBooks();
}
