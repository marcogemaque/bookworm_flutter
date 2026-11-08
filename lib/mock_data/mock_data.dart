import '../data_model/book.dart';

List<Book> getMockBooks() {
  final now = DateTime.now();

  return [
    Book(
      title: 'This is How You Lose the Time War',
      authors: ['Amal El-Mohtar', 'Max Gladstone'],
      isRead: true,
      dateStarted: now.subtract(const Duration(days: 10)),
      dateFinished: now.subtract(const Duration(days: 7)),
      genre: ['Sci-Fi', 'Romance', 'Epistolary'],
      rating: 5,
      coverUrl: 'https://covers.openlibrary.org/b/id/8665647-M.jpg',
      addedOnDate: now.subtract(const Duration(days: 15)),
    ),

    Book(
      title: 'Project Hail Mary',
      authors: ['Andy Weir'],
      isRead: false,
      dateStarted: now.subtract(const Duration(days: 2)),
      dateFinished: null,
      genre: ['Sci-Fi', 'Thriller'],
      rating: null,
      coverUrl: 'https://covers.openlibrary.org/b/id/10521268-M.jpg',
      addedOnDate: now.subtract(const Duration(days: 5)),
    ),

    Book(
      title: 'The Hobbit',
      authors: ['J.R.R. Tolkien'],
      isRead: true,
      dateStarted: now.subtract(const Duration(days: 30)),
      dateFinished: now.subtract(const Duration(days: 25)),
      genre: ['Fantasy', 'Adventure'],
      rating: 4,
      coverUrl: 'https://covers.openlibrary.org/b/id/8229423-M.jpg',
      addedOnDate: now.subtract(const Duration(days: 40)),
    ),

    Book(
      title: '1984',
      authors: ['George Orwell'],
      isRead: true,
      dateStarted: now.subtract(const Duration(days: 5)),
      dateFinished: now.subtract(const Duration(days: 3)),
      genre: ['Dystopian', 'Classic', 'Political Fiction'],
      rating: 5,
      coverUrl: 'https://covers.openlibrary.org/b/id/7222246-M.jpg',
      addedOnDate: now.subtract(const Duration(days: 8)),
    ),

    Book(
      title: 'The Seven Husbands of Evelyn Hugo',
      authors: ['Taylor Jenkins Reid'],
      isRead: false,
      dateStarted: now.subtract(const Duration(days: 7)),
      dateFinished: null,
      genre: ['Historical Fiction', 'Romance', 'LGBTQ+'],
      rating: null,
      coverUrl: 'https://covers.openlibrary.org/b/id/8545635-M.jpg',
      addedOnDate: now.subtract(const Duration(days: 10)),
    ),

    Book(
      title: 'Sapiens: A Brief History of Humankind',
      authors: ['Yuval Noah Harari'],
      isRead: true,
      dateStarted: now.subtract(const Duration(days: 120)),
      dateFinished: now.subtract(const Duration(days: 100)),
      genre: ['Non-Fiction', 'History', 'Anthropology'],
      rating: 4,
      coverUrl: 'https://covers.openlibrary.org/b/id/8229423-M.jpg',
      addedOnDate: now.subtract(const Duration(days: 150)),
    ),

    Book(
      title: 'The Silent Patient',
      authors: ['Alex Michaelides'],
      isRead: false,
      dateStarted: null,
      dateFinished: null,
      genre: ['Mystery', 'Thriller', 'Psychological Fiction'],
      rating: null,
      coverUrl: 'https://covers.openlibrary.org/b/id/9880936-M.jpg',
      addedOnDate: now.subtract(const Duration(days: 1)),
    ),

    Book(
      title: 'Normal People',
      authors: ['Sally Rooney'],
      isRead: true,
      dateStarted: now.subtract(const Duration(days: 14)),
      dateFinished: now.subtract(const Duration(days: 1)),
      genre: ['Contemporary Fiction', 'Romance', 'Literary Fiction'],
      rating: 3,
      coverUrl: 'https://covers.openlibrary.org/b/id/9255668-M.jpg',
      addedOnDate: now.subtract(const Duration(days: 20)),
    ),

    Book(
      title: 'The Shining',
      authors: ['Stephen King'],
      isRead: true,
      dateStarted: now.subtract(const Duration(days: 200)),
      dateFinished: now.subtract(const Duration(days: 190)),
      genre: ['Horror', 'Thriller', 'Supernatural'],
      rating: 2,
      coverUrl: 'https://covers.openlibrary.org/b/id/8231898-M.jpg',
      addedOnDate: now.subtract(const Duration(days: 250)),
    ),

    Book(
      title: 'Meditations',
      authors: ['Marcus Aurelius'],
      isRead: false,
      dateStarted: now.subtract(const Duration(days: 45)),
      dateFinished: null,
      genre: ['Philosophy', 'Classic', 'Non-Fiction'],
      rating: null,
      coverUrl: 'https://covers.openlibrary.org/b/id/8229423-M.jpg',
      addedOnDate: now.subtract(const Duration(days: 60)),
    ),
  ];
}

List<VocabularyEntry> getMockVocabulary() {
  final now = DateTime.now();

  return [
    VocabularyEntry(
      word: 'Epistolary',
      definition: 'A novel, play, or other literary work written in the form of a series of letters.',
      bookId: 1, // Links to "This is How You Lose the Time War"
    ),
    VocabularyEntry(
      word: 'Doublethink',
      definition: 'The act of simultaneously accepting two mutually contradictory beliefs as correct.',
      bookId: 4, // Links to "1984"
    ),
    VocabularyEntry(
      word: 'Orwellian',
      definition: 'Situations, ideas, or societal conditions that George Orwell identified as destructive to a free society.',
      bookId: 4, // Links to "1984"
    ),
    VocabularyEntry(
      word: 'Cognitive Revolution',
      definition: 'The change in human behavior and thought that took place in Europe around 70,000 years ago.',
      bookId: 6, // Links to "Sapiens"
    ),
    VocabularyEntry(
      word: 'Ephemeral',
      definition: 'Lasting for a very short time.',
      bookId: 10, // Links to "Meditations"
    ),
    VocabularyEntry(
      word: 'Amor Fati',
      definition: 'A Latin phrase that may be translated as "love of fate" or "love of one\'s fate".',
      bookId: 10, // Links to "Meditations"
    ),
  ];
}
