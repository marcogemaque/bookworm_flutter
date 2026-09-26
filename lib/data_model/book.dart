import 'dart:convert';

class Book {
  final int? id;
  final String title;
  final List<String> authors;
  final bool isRead;

  // Make these non-nullable and default to empty lists!
  final List<String> genre;
  final List<String> notes;

  Book({
    this.id,
    required this.title,
    required this.authors,
    this.isRead = false,
    this.genre = const [], // Defaults to empty list, never null
    this.notes = const [], // Defaults to empty list, never null
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      // The ?? [] ensures we NEVER encode null. It will save "[]" instead of "null"
      'authors': jsonEncode(authors ?? []),
      'isRead': isRead ? 1 : 0,
      'genre': jsonEncode(genre ?? []),
      'notes': jsonEncode(notes ?? []),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      authors: _safeDecode(map['authors']),
      isRead: map['isRead'] == 1,
      genre: _safeDecode(map['genre']),
      notes: _safeDecode(map['notes']),
    );
  }

  // This helper safely handles SQL NULL, the string "null", and valid JSON
  static List<String> _safeDecode(dynamic value) {
    if (value == null) return []; // Handles SQL NULL
    if (value is String && value == 'null')
      return []; // Handles the literal string "null"

    try {
      final decoded = jsonDecode(value);
      return decoded is List ? List<String>.from(decoded) : [];
    } catch (e) {
      return []; // Fallback if the JSON is somehow malformed
    }
  }

  // Don't forget your copyWith method!
  Book copyWith({
    int? id,
    String? title,
    List<String>? authors,
    bool? isRead,
    List<String>? genre,
    List<String>? notes,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      isRead: isRead ?? this.isRead,
      genre: genre ?? this.genre,
      notes: notes ?? this.notes,
    );
  }
}
