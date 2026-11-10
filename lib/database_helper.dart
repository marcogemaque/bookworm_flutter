import 'package:sqflite/sqflite.dart';
import 'package:bookworm/data_model/book.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:bookworm/mock_data/mock_data.dart';

class DatabaseHelper {
  // Singleton
  static final int _dbVersion = 3;
  static final String _tableName = 'books';
  static final String _vocabTableName = 'vocabulary';
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  static Database? _database;

  // Getter for DB
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database!
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'books_database.db');

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $_tableName ADD COLUMN isAudiobook INTEGER',
      );
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE $_vocabTableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word TEXT NOT NULL,
          definition TEXT,
          bookId INTEGER
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        authors TEXT,
        isRead INTEGER NOT NULL DEFAULT 0,
        genre TEXT,
        rating INTEGER,
        notes TEXT,
        dateStarted INTEGER,
        dateFinished INTEGER,
        coverUrl TEXT,
        addedOnDate INTEGER NOT NULL,
        isAudiobook INTEGER
      )
    ''');
    // added for v3 -> new vocab table
    await db.execute('''
      CREATE TABLE $_vocabTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        definition TEXT,
        bookId INTEGER
      )
    ''');
  }

  // INSERT: Adds a new book to the database
  Future<int> insertBook(Book book) async {
    Database db = await instance.database;
    return await db.insert(_tableName, book.toMap());
  }

  // READ: Gets all books from the database
  Future<List<Book>> getBooks() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  // DELETE: Removes a book ID from the database
  Future<int> deleteBook(Book book) async {
    Database db = await instance.database;
    if (book.id == null) return 0;
    return await db.delete(_tableName, where: "id=?", whereArgs: [book.id]);
  }

  //we added this so people can edit a book
  Future<int> updateBook(Book book) async {
    Database db = await instance.database;
    if (book.id == null) return 0;
    return await db.update(
      _tableName,
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  //we created this so people can edit a vocabulary word
  Future<int> updateVocabulary(VocabularyEntry entry) async {
    Database db = await instance.database;
    if (entry.id == null) return 0;
    return await db.update(
      _vocabTableName,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  Future<void> seedDatabaseIfEmpty() async {
    if (kReleaseMode) return;

    try {
      final existingBooks = await getBooks();

      if (existingBooks.isEmpty) {
        debugPrint('Database is empty. Seeding with mock books...');
        final mockBooks = getMockBooks();

        for (final book in mockBooks) {
          await insertBook(book);
        }
        //now we create the mock vocabulary we had
        final mockVocab = getMockVocabulary();
        for (final vocab in mockVocab) {
          await insertVocabulary(vocab);
        }
        debugPrint('Successfully seeded ${mockBooks.length} mock books.');
      }
    } catch (e) {
      debugPrint('Error seeding database: $e');
    }
  }

  Future<List<int>> getReadYears() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT dateFinished FROM $_tableName WHERE dateFinished IS NOT NULL AND isRead = 1',
    );

    final Set<int> years = {};
    for (var map in maps) {
      final timestamp = map['dateFinished'] as int?;
      if (timestamp != null && timestamp > 0) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        years.add(date.year);
      }
    }

    final sortedYears = years.toList()..sort();
    return sortedYears;
  }

  Future<int> insertVocabulary(VocabularyEntry entry) async {
    final db = await database;
    return await db.insert(_vocabTableName, entry.toMap());
  }

  Future<List<VocabularyEntry>> getAllVocabularyEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _vocabTableName,
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) => VocabularyEntry.fromMap(maps[i]));
  }

  Future<Map<String, List<String>>> getVocabularyAsTwoLists() async {
    final entries = await getAllVocabularyEntries();

    final List<String> wordsList = entries.map((entry) => entry.word).toList();

    final List<String> definitionsList = entries
        .map((entry) => entry.definition ?? 'No definition provided')
        .toList();

    return {'words': wordsList, 'definitions': definitionsList};
  }

  Future<List<String>> getUniqueVocabularyWords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT word FROM $_vocabTableName ORDER BY word ASC
    ''');
    return maps.map((map) => map['word'] as String).toList();
  }

  Future<int> deleteVocabulary(int id) async {
    final db = await database;
    return await db.delete(_vocabTableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<VocabularyEntry>> getVocabularyByBook(int bookId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _vocabTableName,
      where: 'bookId = ?',
      whereArgs: [bookId],
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) => VocabularyEntry.fromMap(maps[i]));
  }
}
