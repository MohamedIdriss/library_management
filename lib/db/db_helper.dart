import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';
import '../models/author.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('library.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Table for books
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        isbn TEXT NOT NULL,
        dateSortie TEXT NOT NULL,
        photo TEXT,
        writerId INTEGER NOT NULL,
              favorite INTEGER NOT NULL DEFAULT 0,
                    FOREIGN KEY (writerId) REFERENCES authors(id) ON DELETE CASCADE


      )
    ''');

    await db.execute('''
      CREATE TABLE authors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        phone TEXT NOT NULL
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }


  Future<int> createBook(Book book) async {
    final db = await instance.database;
    return await db.insert('books', book.toMap());
  }

  Future<List<Book>> fetchAllBooks() async {
    final db = await instance.database;
    final result = await db.query('books');
    return result.map((json) => Book.fromMap(json)).toList();
  }

  Future<int> updateBook(Book book) async {
    final db = await instance.database;
    return await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> deleteBook(int id) async {
    final db = await instance.database;
    return await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<int>  toggleFavorite(int id ,int favoris) async {
    Database db = await instance.database;
    return await db.update('books',  {'favorite' : favoris}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Book>> fetchFavoriteBooks() async {
    final db = await instance.database;

    final maps = await db.query(
      'books',
      where: 'favorite = ?',
      whereArgs: [1],
    );

    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }


  Future<int> createAuthor(Author author) async {
    final db = await instance.database;
    return await db.insert('authors', author.toMap());
  }

  Future<List<Author>> fetchAllAuthors() async {
    final db = await instance.database;
    final result = await db.query('authors');
    return result.map((json) => Author.fromMap(json)).toList();
  }

  Future<int> updateAuthor(Author author) async {
    final db = await instance.database;
    return await db.update(
      'authors',
      author.toMap(),
      where: 'id = ?',
      whereArgs: [author.id],
    );
  }

  Future<int> deleteAuthor(int id) async {
    final db = await instance.database;
    return await db.delete(
      'authors',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<List<Author>> searchAuthors(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'authors',
      where: 'firstName LIKE ? OR lastName LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return result.map((json) => Author.fromMap(json)).toList();
  }



  Future<List<Author>> getAuthors() async {
    final db = await database;
    final result = await db.query('authors');
    return result.map((authorMap) => Author.fromMap(authorMap)).toList();
  }
}
