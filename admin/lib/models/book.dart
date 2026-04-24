class Book {
  final String id;
  final String ownerId;
  final String title;
  final String slug;
  final String? description;
  final String? originalPdfUrl;
  final String status; // 'processing', 'completed', 'failed'
  final bool isPublished;
  final String? author;
  final String? seoTitle;
  final String? seoDescription;
  final List<String> seoTags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Book({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.slug,
    this.description,
    this.originalPdfUrl,
    required this.status,
    required this.isPublished,
    this.author,
    this.seoTitle,
    this.seoDescription,
    required this.seoTags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      originalPdfUrl: json['original_pdf_url'] as String?,
      status: json['status'] as String,
      isPublished: json['is_published'] as bool? ?? false,
      author: json['author'] as String?,
      seoTitle: json['seo_title'] as String?,
      seoDescription: json['seo_description'] as String?,
      seoTags: (json['seo_tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'slug': slug,
      'description': description,
      'original_pdf_url': originalPdfUrl,
      'status': status,
      'is_published': isPublished,
      'author': author,
      'seo_title': seoTitle,
      'seo_description': seoDescription,
      'seo_tags': seoTags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Book copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? slug,
    String? description,
    String? originalPdfUrl,
    String? status,
    bool? isPublished,
    String? author,
    String? seoTitle,
    String? seoDescription,
    List<String>? seoTags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      originalPdfUrl: originalPdfUrl ?? this.originalPdfUrl,
      status: status ?? this.status,
      isPublished: isPublished ?? this.isPublished,
      author: author ?? this.author,
      seoTitle: seoTitle ?? this.seoTitle,
      seoDescription: seoDescription ?? this.seoDescription,
      seoTags: seoTags ?? this.seoTags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
