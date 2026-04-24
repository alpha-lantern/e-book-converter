import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/book.dart';

part 'book_repository.g.dart';

class BookRepository {
  final SupabaseClient _supabase;

  BookRepository(this._supabase);

  Future<List<Book>> getBooks() async {
    final response = await _supabase
        .from('books')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((json) => Book.fromJson(json)).toList();
  }

  Future<Book> createBook(String filePath) async {
    final file = File(filePath);
    final fileName = filePath.split('/').last;
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final storagePath = '${user.id}/$fileName';

    // 1. Upload PDF to storage
    await _supabase.storage.from('raw_pdfs').upload(
          storagePath,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    final publicUrl = _supabase.storage.from('raw_pdfs').getPublicUrl(storagePath);

    // 2. Create database record
    final response = await _supabase.from('books').insert({
      'owner_id': user.id,
      'title': fileName.replaceAll('.pdf', ''),
      'slug': '${fileName.replaceAll('.pdf', '').toLowerCase()}-${DateTime.now().millisecondsSinceEpoch}',
      'original_pdf_url': publicUrl,
      'status': 'processing',
    }).select().single();

    return Book.fromJson(response);
  }

  Future<void> updateBookMetadata(Book book) async {
    await _supabase.from('books').update({
      'author': book.author,
      'seo_title': book.seoTitle,
      'seo_description': book.seoDescription,
      'seo_tags': book.seoTags,
    }).eq('id', book.id);
  }
}

@riverpod
BookRepository bookRepository(BookRepositoryRef ref) {
  return BookRepository(Supabase.instance.client);
}
