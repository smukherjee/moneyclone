// Web platform implementations
import 'package:sqflite/sqflite.dart';

bool get isWindows => false;
bool get isLinux => false;
bool get isMacOS => false;
bool get isAndroid => false;
bool get isIOS => false;

// This function is a no-op for web, as we're using memory database
Future<String> getWebDatabasePath() async {
  return ':memory:';
}
