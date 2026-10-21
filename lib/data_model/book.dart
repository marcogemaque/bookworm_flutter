import 'dart:convert';

class Book {
  final int? id;
  final String title;
  final List<String>? authors;
  final bool isRead;
  final DateTime? dateStarted;
  final DateTime? dateFinished;
  final List<String> genre;
  final String? notes;
  final int? rating;
  final String? coverUrl;
  final DateTime addedOnDate;
  final bool? isAudiobook; // Optional boolean

  Book({
    this.id,
    required this.title,
    this.authors,
    this.isRead = false,
    this.genre = const [],
    this.notes,
    this.dateStarted,
    this.dateFinished,
    this.rating,
    this.coverUrl,
    required this.addedOnDate,
    this.isAudiobook,
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
      'addedOnDate': addedOnDate.millisecondsSinceEpoch,
      // Safely store null as null, otherwise 1 or 0
      'isAudiobook': isAudiobook == null ? null : (isAudiobook! ? 1 : 0),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      authors: _safeDecodeNullable(map['authors']),
      isRead: map['isRead'] == 1,
      genre: _safeDecode(map['genre']),
      notes: map['notes'],
      rating: map['rating'],
      dateStarted: map['dateStarted'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateStarted'] as int)
          : null,
      dateFinished: map['dateFinished'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateFinished'] as int)
          : null,
      coverUrl: map['coverUrl'],
      addedOnDate: DateTime.fromMillisecondsSinceEpoch(
        map['addedOnDate'] as int,
      ),
      // Correctly parse null, 1, or 0
      isAudiobook: map['isAudiobook'] == null ? null : map['isAudiobook'] == 1,
    );
  }

  static List<String> _safeDecode(dynamic value) {
    if (value == null) return [];
    if (value is String && value == 'null') return [];

    try {
      final decoded = jsonDecode(value);
      return decoded is List ? List<String>.from(decoded) : [];
    } catch (e) {
      return [];
    }
  }

  static List<String>? _safeDecodeNullable(dynamic value) {
    if (value == null) return null;
    if (value is String && value == 'null') return null;

    try {
      final decoded = jsonDecode(value);
      return decoded is List ? List<String>.from(decoded) : null;
    } catch (e) {
      return null;
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
      'dateFinished': dateFinished?.toIso8601String(), // Fixed typo here
      'notes': notes,
      'coverUrl': coverUrl,
      'addedOnDate': addedOnDate.toIso8601String(),
      'isAudiobook': isAudiobook,
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
    DateTime? addedOnDate,
    bool? isAudiobook, // Fixed: was int?
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
      addedOnDate: addedOnDate ?? this.addedOnDate,
      isAudiobook: isAudiobook ?? this.isAudiobook,
    );
  }
}
