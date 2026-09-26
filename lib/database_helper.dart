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
        authors TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        genre TEXT,
        notes TEXT
      )
    ''');
  }

  // --- DATABASE ACTIONS (CRUD) ---

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
}
