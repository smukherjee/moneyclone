import 'package:sqflite/sqflite.dart';
import 'package:money_clone/data/platform_interface.dart';

class DatabaseHelperWeb {
  static final DatabaseHelperWeb _instance = DatabaseHelperWeb._internal();
  static Database? _database;

  factory DatabaseHelperWeb() {
    return _instance;
  }

  DatabaseHelperWeb._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final platform = PlatformWeb();
    final path = await platform.getDatabasePath();
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create tables
        await db.execute('''
          CREATE TABLE accounts (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            balance REAL NOT NULL,
            type TEXT NOT NULL,
            color INTEGER NOT NULL,
            icon INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            account_id TEXT NOT NULL,
            category TEXT NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            date TEXT NOT NULL,
            notes TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }
}
