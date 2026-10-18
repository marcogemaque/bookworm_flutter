import 'package:sqflite/sqflite.dart';
import 'package:bookworm/data_model/book.dart'; // Import our Book model
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton
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
    // getDatabasesPath() finds the right folder on iOS/Android
    String path = join(await getDatabasesPath(), 'books_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate:
          _onCreate, // Calls the function below when the DB is first created
    );
  }

  // 4. The SQL command to build our table!
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
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
        addedOnDate INTEGER
      )
    ''');
  }

  // INSERT: Adds a new book to the database
  Future<int> insertBook(Book book) async {
    Database db = await instance.database;
    return await db.insert('books', book.toMap());
  }

  // READ: Gets all books from the database
  Future<List<Book>> getBooks() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('books');

    // Converts the list of Maps into a list of Book objects
    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  // DELETE: Removes a book ID from the database
  Future<int> deleteBook(Book book) async {
    Database db = await instance.database;
    return await db.delete("books", where: "id=?", whereArgs: [book.id]);
  }

  // UPDATE: Updates a book (useful for marking a book as "Read")
  Future<int> updateBook(Book book) async {
    Database db = await instance.database;
    return await db.update(
      'books',
      book.toMap(),
      where: 'id = ?', // Only update the book with this specific ID
      whereArgs: [book.id],
    );
  }

  Future<List<Book>> getAllBooks() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('books');
    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  Future<List<int>> getReadYears() async {
    final db = await database;

    // Fetch distinct timestamps where the book is finished and marked as read
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT dateFinished FROM books WHERE dateFinished IS NOT NULL AND isRead = 1',
    );

    final Set<int> years = {};
    for (var map in maps) {
      final timestamp = map['dateFinished'] as int?;
      if (timestamp != null && timestamp > 0) {
        // Convert milliseconds timestamp to DateTime and extract the year
        // (If your app stores seconds instead of milliseconds, use: timestamp * 1000)
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        years.add(date.year);
      }
    }

    final sortedYears = years.toList()..sort();
    return sortedYears;
  }
}
