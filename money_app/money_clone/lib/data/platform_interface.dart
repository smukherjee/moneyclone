import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

abstract class PlatformInterface {
  Future<String> getDatabasePath();
}

class PlatformWeb implements PlatformInterface {
  @override
  Future<String> getDatabasePath() async {
    // For web, we'll use an in-memory database
    return ':memory:';
  }
}

class PlatformNative implements PlatformInterface {
  @override
  Future<String> getDatabasePath() async {
    if (kIsWeb) {
      throw UnsupportedError('Native platform interface called on web');
    }
    
    final dbPath = await getApplicationDocumentsDirectory();
    return dbPath.path;
  }
}
