import 'package:flutter/material.dart';
import 'package:money_clone/data/database_helper.dart';
import 'package:money_clone/data/web_database_helper.dart';
import 'package:money_clone/logic/providers.dart';
import 'package:money_clone/ui/auth_screen.dart';
import 'package:money_clone/ui/main_screen.dart';
import 'package:money_clone/ui/theme.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Import platform helper
import 'src/platform_helper.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize platform-specific features
  if (kIsWeb) {
    // Initialize web database
    try {
      print("Initializing web database...");
      await WebDatabaseHelper.initialize();
      print("Web database initialization successful");
    } catch (e) {
      print("Error initializing web database: $e");
      print("Stack trace: ${StackTrace.current}");
    }
  } else {
    // Initialize native platform features
    initPlatformSpecificFeatures();
  }
  
  // Initialize database
  try {
    await DatabaseHelper().database;
  } catch (e) {
    print("Database initialization error: $e");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: MaterialApp(
        title: "Money Clone",
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const AuthScreen(child: MainScreen()),
      ),
    );
  }
}
