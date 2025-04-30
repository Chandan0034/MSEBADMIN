import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'media.db');

    // Delete existing database for a fresh start
    await deleteDatabase(path);

    // Create and open a new database
    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE images(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            url TEXT UNIQUE,
            description TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  Future<int> insertImage(String url, String description) async {
    final db = await database;
    try {
      return await db.insert(
        'images',
        {'url': url, 'description': description},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      print('Error inserting image: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getAllImages() async {
    final db = await database;
    return await db.query('images');
  }

  Future<void> clearTable() async {
    final db = await database;
    await db.delete('images');
  }
}
