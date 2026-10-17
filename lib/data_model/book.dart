import 'dart:convert';

class Book {
  final int? id;
  final String title;
  final List<String>? authors;
  final bool isRead;
  final DateTime? dateStarted;
  final DateTime? dateFinished;
  // Make these non-nullable and default to empty lists!
  final List<String> genre;
  final String? notes;
  //ratings for
  final int? rating;
  final String? coverUrl;

  Book({
    this.id,
    required this.title,
    this.authors,
    this.isRead = false,
    this.genre = const [], // Defaults to empty list, never null
    this.notes, // Defaults to empty list, never null
    this.dateStarted,
    this.dateFinished,
    this.rating,
    this.coverUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'authors': jsonEncode(authors),
      'isRead': isRead ? 1 : 0,
      'genre': jsonEncode(genre),
      'notes': notes,
      'rating': rating,
      'dateStarted': dateStarted?.millisecondsSinceEpoch,
      'dateFinished': dateFinished?.millisecondsSinceEpoch,
      'coverUrl': coverUrl,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      authors: _safeDecode(map['authors']),
      isRead: map['isRead'] == 1,
      genre: _safeDecode(map['genre']),
      notes: map['notes'],
      rating: map['rating'],
      //Convert INTEGER back to DateTime (or null if it doesn't exist)
      dateStarted: map['dateStarted'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateStarted'] as int)
          : null,
      dateFinished: map['dateFinished'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateFinished'] as int)
          : null,
      coverUrl: map['coverUrl'],
    );
  }

  // This helper safely handles SQL NULL, the string "null", and valid JSON
  static List<String> _safeDecode(dynamic value) {
    if (value == null) return []; // Handles SQL NULL
    if (value is String && value == 'null') {
      return []; // Handles the literal string "null"
    }

    try {
      final decoded = jsonDecode(value);
      return decoded is List ? List<String>.from(decoded) : [];
    } catch (e) {
      return []; // Fallback if the JSON is somehow malformed
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'genre': genre,
      'rating': rating,
      'dateStarted': dateStarted?.toIso8601String(),
      'dateFinishd': dateFinished?.toIso8601String(),
      'notes': notes,
      'coverUrl': coverUrl,
    };
  }

  Book copyWith({
    int? id,
    String? title,
    List<String>? authors,
    bool? isRead,
    List<String>? genre,
    String? notes,
    int? rating,
    DateTime? dateStarted,
    DateTime? dateFinished,
    String? coverUrl,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      isRead: isRead ?? this.isRead,
      genre: genre ?? this.genre,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      dateStarted: dateStarted ?? this.dateStarted,
      dateFinished: dateFinished ?? this.dateFinished,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }
}
