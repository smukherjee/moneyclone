import 'dart:async';

import 'package:money_clone/data/models.dart' as models;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'money_clone.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT,
        description TEXT,
        paymentMethod TEXT NOT NULL,
        accountId TEXT,
        FOREIGN KEY (accountId) REFERENCES accounts(id) ON DELETE SET NULL
      )
    ''');

    // Create accounts table
    await db.execute('''
      CREATE TABLE accounts(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        balance REAL NOT NULL,
        accountNumber TEXT,
        bankName TEXT
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT,
        type TEXT NOT NULL
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
    
    // Create a default account
    await _createDefaultAccount(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final expenseCategories = [
      {'name': 'Food & Dining', 'type': models.TransactionType.expense.toString()},
      {'name': 'Shopping', 'type': models.TransactionType.expense.toString()},
      {'name': 'Housing', 'type': models.TransactionType.expense.toString()},
      {'name': 'Transportation', 'type': models.TransactionType.expense.toString()},
      {'name': 'Entertainment', 'type': models.TransactionType.expense.toString()},
      {'name': 'Health & Fitness', 'type': models.TransactionType.expense.toString()},
      {'name': 'Personal Care', 'type': models.TransactionType.expense.toString()},
      {'name': 'Education', 'type': models.TransactionType.expense.toString()},
      {'name': 'Travel', 'type': models.TransactionType.expense.toString()},
      {'name': 'Gifts & Donations', 'type': models.TransactionType.expense.toString()},
      {'name': 'Bills & Utilities', 'type': models.TransactionType.expense.toString()},
      {'name': 'Other', 'type': models.TransactionType.expense.toString()},
    ];

    final incomeCategories = [
      {'name': 'Salary', 'type': models.TransactionType.income.toString()},
      {'name': 'Business', 'type': models.TransactionType.income.toString()},
      {'name': 'Investments', 'type': models.TransactionType.income.toString()},
      {'name': 'Rental Income', 'type': models.TransactionType.income.toString()},
      {'name': 'Gifts', 'type': models.TransactionType.income.toString()},
      {'name': 'Other', 'type': models.TransactionType.income.toString()},
    ];    final transferCategories = [
      {'name': 'Account Transfer', 'type': models.TransactionType.transfer.toString()},
    ];

    // Use UUID for IDs
    final uuid = Uuid();
    
    for (var category in [...expenseCategories, ...incomeCategories, ...transferCategories]) {
      await db.insert('categories', {
        'id': uuid.v4(),
        'name': category['name'],
        'icon': null,
        'type': category['type'],
      });
    }
  }
  
  Future<void> _createDefaultAccount(Database db) async {
    final uuid = Uuid();
    await db.insert('accounts', {
      'id': uuid.v4(),
      'name': 'Cash',
      'balance': 0.0,
      'accountNumber': null,
      'bankName': null,
    });
  }

  // Transaction operations
  Future<String> insertTransaction(models.Transaction transaction) async {
    final db = await database;
    
    // If it's a new transaction with no ID, generate one
    final id = transaction.id.isEmpty ? Uuid().v4() : transaction.id;
    final transactionMap = transaction.toMap();
    transactionMap['id'] = id;
    
    await db.insert('transactions', transactionMap);
    
    // Update account balance
    if (transaction.accountId != null) {
      await _updateAccountBalance(transaction.accountId!, transaction);
    }
    
    return id;
  }

  Future<List<models.Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? accountId,
    String? categoryId,
    models.TransactionType? type,
  }) async {
    final db = await database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];
    
    if (startDate != null) {
      whereClause += ' AND date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      whereClause += ' AND date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    if (accountId != null) {
      whereClause += ' AND accountId = ?';
      whereArgs.add(accountId);
    }
    
    if (categoryId != null) {
      whereClause += ' AND category = ?';
      whereArgs.add(categoryId);
    }
    
    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type.toString());
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return models.Transaction.fromMap(maps[i]);
    });
  }

  Future<models.Transaction?> getTransaction(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return models.Transaction.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTransaction(models.Transaction transaction) async {
    final db = await database;
    
    // Get the old transaction to calculate balance difference
    final oldTransaction = await getTransaction(transaction.id);
    
    final result = await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    
    // Update account balance
    if (transaction.accountId != null && oldTransaction != null) {
      // If account changed, update both accounts
      if (oldTransaction.accountId != transaction.accountId) {
        if (oldTransaction.accountId != null) {
          // Reverse the old transaction effect
          await _updateAccountBalance(
            oldTransaction.accountId!,
            oldTransaction,
            isReversal: true,
          );
        }
        // Apply new transaction
        await _updateAccountBalance(transaction.accountId!, transaction);
      } else {
        // Same account, update with the difference
        await _updateAccountBalanceDifference(
          transaction.accountId!,
          oldTransaction,
          transaction,
        );
      }
    }
    
    return result;
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    
    // Get the transaction before deleting to update account balance
    final transaction = await getTransaction(id);
    
    final result = await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    // Update account balance
    if (transaction != null && transaction.accountId != null) {
      await _updateAccountBalance(
        transaction.accountId!,
        transaction,
        isReversal: true,
      );
    }
    
    return result;
  }

  // Account operations
  Future<String> insertAccount(models.Account account) async {
    final db = await database;
    
    // If it's a new account with no ID, generate one
    final id = account.id.isEmpty ? Uuid().v4() : account.id;
    final accountMap = account.toMap();
    accountMap['id'] = id;
    
    await db.insert('accounts', accountMap);
    return id;
  }

  Future<List<models.Account>> getAccounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('accounts');
    return List.generate(maps.length, (i) {
      return models.Account.fromMap(maps[i]);
    });
  }

  Future<models.Account?> getAccount(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return models.Account.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateAccount(models.Account account) async {
    final db = await database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteAccount(String id) async {
    final db = await database;
    
    // First, check if account has transactions
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'accountId = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      // Has transactions, set their accountId to null
      await db.update(
        'transactions',
        {'accountId': null},
        where: 'accountId = ?',
        whereArgs: [id],
      );
    }
    
    // Now delete the account
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Category operations
  Future<String> insertCategory(models.Category category) async {
    final db = await database;
    
    // If it's a new category with no ID, generate one
    final id = category.id.isEmpty ? Uuid().v4() : category.id;
    final categoryMap = category.toMap();
    categoryMap['id'] = id;
    
    await db.insert('categories', categoryMap);
    return id;
  }

  Future<List<models.Category>> getCategories({models.TransactionType? type}) async {
    final db = await database;
    String? whereClause;
    List<String>? whereArgs;
    
    if (type != null) {
      whereClause = 'type = ?';
      whereArgs = [type.toString()];
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
    );
    
    return List.generate(maps.length, (i) {
      return models.Category.fromMap(maps[i]);
    });
  }

  Future<models.Category?> getCategory(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return models.Category.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCategory(models.Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(String id) async {
    final db = await database;
    
    // First, update any transactions using this category to null
    await db.update(
      'transactions',
      {'category': null},
      where: 'category = ?',
      whereArgs: [id],
    );
    
    // Now delete the category
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Private helper methods for updating account balances
  Future<void> _updateAccountBalance(
    String accountId,
    models.Transaction transaction, {
    bool isReversal = false,
  }) async {
    final db = await database;
    final account = await getAccount(accountId);
    if (account == null) return;
    
    double balanceChange = 0;
    
    switch (transaction.type) {
      case models.TransactionType.income:
        balanceChange = transaction.amount;
        break;
      case models.TransactionType.expense:
        balanceChange = -transaction.amount;
        break;
      case models.TransactionType.transfer:
        // For transfers, we need to know if this is source or destination account
        // This would be handled better with a more complex transfer model
        balanceChange = -transaction.amount;
        break;
    }
    
    // If reversing (e.g., for deletion), invert the change
    if (isReversal) {
      balanceChange = -balanceChange;
    }
    
    final newBalance = account.balance + balanceChange;
    
    await db.update(
      'accounts',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  Future<void> _updateAccountBalanceDifference(
    String accountId,
    models.Transaction oldTransaction,
    models.Transaction newTransaction,
  ) async {
    final db = await database;
    final account = await getAccount(accountId);
    if (account == null) return;
    
    double oldEffect = 0;
    double newEffect = 0;
    
    // Calculate old transaction effect
    switch (oldTransaction.type) {
      case models.TransactionType.income:
        oldEffect = oldTransaction.amount;
        break;
      case models.TransactionType.expense:
        oldEffect = -oldTransaction.amount;
        break;
      case models.TransactionType.transfer:
        oldEffect = -oldTransaction.amount;
        break;
    }
    
    // Calculate new transaction effect
    switch (newTransaction.type) {
      case models.TransactionType.income:
        newEffect = newTransaction.amount;
        break;
      case models.TransactionType.expense:
        newEffect = -newTransaction.amount;
        break;
      case models.TransactionType.transfer:
        newEffect = -newTransaction.amount;
        break;
    }
    
    // Calculate the net change
    final netChange = newEffect - oldEffect;
    
    // Update account balance
    final newBalance = account.balance + netChange;
    
    await db.update(
      'accounts',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  // Get summary data
  Future<Map<String, double>> getCategorySummary({
    DateTime? startDate,
    DateTime? endDate,
    String? accountId,
    models.TransactionType? type,
  }) async {
    final transactions = await getTransactions(
      startDate: startDate,
      endDate: endDate,
      accountId: accountId,
      type: type,
    );
    
    final Map<String, double> result = {};
    
    for (var transaction in transactions) {
      final category = transaction.category ?? 'Uncategorized';
      result[category] = (result[category] ?? 0) + transaction.amount;
    }
    
    return result;
  }

  Future<Map<DateTime, double>> getDailyTransactionSummary({
    DateTime? startDate,
    DateTime? endDate,
    String? accountId,
    models.TransactionType? type,
  }) async {
    final transactions = await getTransactions(
      startDate: startDate,
      endDate: endDate,
      accountId: accountId,
      type: type,
    );
    
    final Map<DateTime, double> result = {};
    
    for (var transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      
      double amount = transaction.amount;
      if (type == null && transaction.type == models.TransactionType.expense) {
        amount = -amount;
      }
      
      result[date] = (result[date] ?? 0) + amount;
    }
    
    return result;
  }
}