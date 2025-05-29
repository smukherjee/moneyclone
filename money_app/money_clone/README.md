# Money Clone - Personal Finance App

A cross-platform personal finance application built with Flutter. This app helps users track their income, expenses, and overall financial health.

## Features

### User Interface
- **Cross-Platform Compatibility**: Works on iOS, Android, Windows, macOS, and Linux
- **Modern UI**: Clean, intuitive interface with dark and light theme support
- **Interactive Charts**: Visual representation of financial data using Syncfusion Charts

### Core Functionality
- **Transaction Management**: Add, edit, and delete financial transactions
- **Categorization**: Categorize transactions for better financial tracking
- **Account Types**: Support for Checking, Savings, Cash, Credit Card, and Investment accounts with customized icons
- **Multiple Accounts**: Manage multiple financial accounts in one place
- **Reports & Analytics**: Gain insights through detailed financial reports
- **Balance Tracking**: Real-time balance updates and total wealth overview

### Security
- **Biometric Authentication**: Secure access with fingerprint or face recognition
- **PIN Protection**: Fallback PIN authentication option
- **Local Storage**: All data stored locally on the device for privacy

### Data Import
- **OCR Technology**: Extract transaction data from receipts and documents
- **Excel Import**: Import financial data from Excel spreadsheets
- **PDF Processing**: Extract data from PDF bank statements

## Architecture

The application is built with a clean architecture approach:

1. **UI Layer**: Flutter UI components
   - Home Screen, Transaction Screen, Reports Screen, Account Screen
   - Reusable widgets for consistent design

2. **Logic Layer**: 
   - Provider pattern for state management
   - Business logic separated from UI

3. **Data Layer**:
   - SQLite for local data storage
   - Repository pattern for data access

4. **Authentication**:
   - Local authentication using device capabilities
   - Secure storage for sensitive information

## Technical Stack

- **Framework**: Flutter
- **Language**: Dart
- **Database**: SQLite with custom data models
- **State Management**: Provider with ChangeNotifier
- **UI Components**: Material Design with custom theming
- **Charts**: Syncfusion Flutter Charts
- **Authentication**: Local Auth
- **OCR**: Google ML Kit
- **Data Helpers**: UUID, Intl formatters

## Getting Started

### Prerequisites
- Flutter SDK (version 3.10.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- For desktop development: platform-specific requirements

### Installation
1. Clone the repository
```
git clone https://github.com/yourusername/money_clone.git
```

2. Install dependencies
```
flutter pub get
```

3. For web platform, set up SQLite:
   - Add SQLite wasm files to your `web` directory:
   ```powershell
   New-Item -ItemType Directory -Path "web/sqlite3" -Force
   Invoke-WebRequest -Uri "https://github.com/simolus3/sqlite3.js/releases/latest/download/sqlite3.wasm" -OutFile "web/sqlite3/sqlite3.wasm"
   Invoke-WebRequest -Uri "https://github.com/simolus3/sqlite3.js/releases/latest/download/sqlite3.js" -OutFile "web/sqlite3/sqlite3.js"
   ```
   
   - Update your `web/index.html` to include SQLite initialization:
   ```html
   <head>
     <!-- Add this before the "main.dart.js" script -->
     <script defer src="sqlite3/sqlite3.js"></script>
     <script>
       window.sqlite3InitModule = function() {
         return initSqlJs({ locateFile: file => `sqlite3/${file}` });
       };
     </script>
   </head>
   ```

4. Run the application
```
flutter run
```

Note: For web deployment, ensure your web server's MIME types include `.wasm` files with the `application/wasm` content type.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Syncfusion](https://www.syncfusion.com/)
- [SQLite](https://www.sqlite.org/)
