import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// This class provides a web-specific database implementation
class WebDatabaseHelper {
  static bool _initialized = false;
  
  /// Initialize the web database factory
  static Future<void> initialize() async {
    if (!kIsWeb) return;
    
    if (!_initialized) {      try {
        // Set databaseFactory to the web implementation
        // The web worker and WASM files need to be in the /web/sqlite3/ directory
        databaseFactory = databaseFactoryFfiWeb;
        _initialized = true;
      }catch (e) {
        print('Error initializing web database: $e');
        rethrow;
      }
    }
  }
  /// Open a database with the given name
  static Future<Database> openWebDatabase(String name, {required int version, required OnDatabaseCreateFn onCreate}) async {
    if (!kIsWeb) {
      throw UnsupportedError('WebDatabaseHelper should only be used on web platform');
    }
    
    await initialize();
    
    try {
      // For web, we'll use IndexedDB via the databaseFactoryFfiWeb
      return await sqflite.openDatabase(
        name,
        version: version,
        onCreate: onCreate,
      );
    } catch (e) {
      print('Error opening web database: $e');
      rethrow;
    }
  }
}
