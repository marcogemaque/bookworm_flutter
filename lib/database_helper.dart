import 'package:sqflite/sqflite.dart';
import 'package:bookworm/data_model/book.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:bookworm/mock_data/mock_data.dart';

class DatabaseHelper {
  // Singleton
  static final int _dbVersion = 2;
  static final String _tableName = 'books';
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
        isAudiobook INTEGER -- ✅ FIX 4: Added to CREATE TABLE for NEW users
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

  // UPDATE: Updates a book
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
}
