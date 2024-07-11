import 'dart:io';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  late Database _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<void> init() async {
    final dataDir = Directory(join(
      Directory.current.path,
      'data',
    ));
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }
    final dbPath = join(
      dataDir.path,
      'herenow.db',
    );
    _database = sqlite3.open(dbPath);

    // 테이블을 생성하자~~
    _database.execute('''
      CREATE TABLE IF NOT EXISTS posts (
        id TEXT PRIMARY KEY,
        title TEXT,
        address TEXT,
        category TEXT,
        image TEXT,
        content TEXT,
        createdAt TEXT
      )
    ''');
  }

  Database get database => _database;
}
