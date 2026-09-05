import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/book.dart';
import 'debug_logger.dart';

part 'book_repository.g.dart';

class BookRepository {
  final SupabaseClient _supabase;
  final DebugLogger _logger;

  BookRepository(this._supabase, this._logger);

  Future<List<Book>> getBooks() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('books')
          .select()
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Book.fromJson(json)).toList();
    } catch (e, st) {
      _logger.logError('BookRepository getBooks failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Book> createBook(String fileName, Uint8List fileBytes) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final baseName = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;
          
      String sanitizedBaseName = baseName.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '-').toLowerCase();
      sanitizedBaseName = sanitizedBaseName.replaceAll(RegExp(r'^-+|-+$'), '');
      if (sanitizedBaseName.isEmpty) {
        sanitizedBaseName = 'ebook';
      }

      final uniqueId = const Uuid().v4();
      final extension = fileName.contains('.') ? fileName.substring(fileName.lastIndexOf('.')) : '';
      final storagePath = '${user.id}/${sanitizedBaseName}_$uniqueId$extension';

      // 1. Upload PDF to storage with error handling
      try {
        await _supabase.storage.from('raw_pdfs').uploadBinary(
              storagePath,
              fileBytes,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );
      } catch (e) {
        throw Exception('Failed to upload PDF to storage: $e');
      }

      final publicUrl = _supabase.storage.from('raw_pdfs').getPublicUrl(storagePath);

      try {
        // 2. Create database record
        final response = await _supabase.from('books').insert({
          'owner_id': user.id,
          'title': baseName,
          'slug': '$sanitizedBaseName-${DateTime.now().millisecondsSinceEpoch}',
          'original_pdf_url': publicUrl,
          'status': BookStatus.processing.name,
        }).select().single();

        return Book.fromJson(response);
      } catch (e) {
        await _supabase.storage.from('raw_pdfs').remove([storagePath]);
        rethrow;
      }
    } catch (e, st) {
      _logger.logError('BookRepository createBook failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Book> updateBookMetadata(Book book) async {
    try {
      final response = await _supabase.from('books').update({
        'author': book.author,
        'seo_title': book.seoTitle,
        'seo_description': book.seoDescription,
        'seo_tags': book.seoTags,
      }).eq('id', book.id).select().single();

      return Book.fromJson(response);
    } catch (e, st) {
      _logger.logError('BookRepository updateBookMetadata failed', error: e, stackTrace: st);
      rethrow;
    }
  }
}

@riverpod
BookRepository bookRepository(BookRepositoryRef ref) {
  return BookRepository(Supabase.instance.client, ref.watch(debugLoggerProvider.notifier));
}

@riverpod
Future<List<Book>> bookList(BookListRef ref) async {
  return ref.watch(bookRepositoryProvider).getBooks();
}
