// Platform-specific code is isolated in this file
// to make it easier to handle web compatibility

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

// Conditionally import platform-specific libraries
import 'platform_io.dart' if (dart.library.html) 'platform_web.dart' as platform;

void initPlatformSpecificFeatures() {
  if (kIsWeb) {
    // Web platform handled separately in WebDatabaseHelper
    return;
  }
  
  // For desktop platforms only
  try {
    if (platform.isWindows || platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  } catch (e) {
    print('Platform initialization error: $e');
  }
}

bool isDesktopPlatform() {
  if (kIsWeb) return false;
  
  try {
    return platform.isWindows || 
           platform.isLinux || 
           platform.isMacOS;
  } catch (e) {
    return false;
  }
}

bool isMobilePlatform() {
  if (kIsWeb) return false;
  
  try {
    return platform.isAndroid || platform.isIOS;
  } catch (e) {
    return false;
  }
}

bool isWebPlatform() {
  return kIsWeb;
}
