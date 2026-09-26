import 'dart:convert';

class Book {
  final int? id;
  final String title;
  final List<String>? authors;
  final bool isRead;
  final List<String>? genre;
  final List<String>? notes;

  Book({
    this.id,
    required this.title,
    this.authors,
    this.isRead = false,
    this.genre,
    this.notes,
  });

  Book copyWith({int? id, String? title, List<String>? authors, bool? isRead}) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'authors': jsonEncode(authors),
      'isRead': isRead ? 1 : 0,
      'genre': jsonEncode(genre),
      'notes': jsonEncode(notes),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      authors: List<String>.from(jsonDecode(map['authors'])),
      isRead: map['isRead'] == 1,
      genre: List<String>.from(jsonDecode(map['genre'])),
      notes: List<String>.from(jsonDecode(map['notes'])),
    );
  }
}
