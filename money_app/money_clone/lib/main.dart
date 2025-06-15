import 'package:flutter/material.dart';
import 'package:money_clone/data/database_helper.dart';
import 'package:money_clone/data/web_database_helper.dart';
import 'package:money_clone/logic/providers.dart';
import 'package:money_clone/ui/auth_screen.dart';
import 'package:money_clone/ui/main_screen.dart';
import 'package:money_clone/ui/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Import platform helper
import 'src/platform_helper.dart';
import 'package:money_clone/utils/logging_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize platform-specific features
  final logger = LoggingService();

  if (kIsWeb) {
    // Initialize web database
    try {
      logger.info("Initializing web database...");
      await WebDatabaseHelper.initialize();
      logger.info("Web database initialization successful");
    } catch (e, stackTrace) {
      logger.error("Error initializing web database", e, stackTrace);
    }
  } else {
    // Initialize native platform features
    initPlatformSpecificFeatures();
  }

  // Initialize database
  try {
    await DatabaseHelper().database;
  } catch (e) {
    logger.error("Database initialization error", e);
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
        home: AuthScreen(child: MainScreen()),
      ),
    );
  }
}
