import 'package:flutter/foundation.dart';
import 'package:money_clone/data/database_helper.dart';
import 'package:money_clone/data/models.dart' as models;

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<models.Transaction> _transactions = [];
  bool _isLoading = false;
  models.TransactionType? _filter;

  TransactionProvider() {
    fetchTransactions();
  }

  List<models.Transaction> get transactions => _filter == null
      ? _transactions
      : _transactions.where((t) => t.type == _filter).toList();

  bool get isLoading => _isLoading;
  models.TransactionType? get filter => _filter;

  void setFilter(models.TransactionType? type) {
    _filter = type;
    notifyListeners();
  }

  void clearFilter() {
    _filter = null;
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _dbHelper.getTransactions();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching transactions: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(models.Transaction transaction) async {
    try {
      await _dbHelper.insertTransaction(transaction);
      await fetchTransactions();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding transaction: $e');
      }
    }
  }

  Future<void> updateTransaction(models.Transaction transaction) async {
    try {
      await _dbHelper.updateTransaction(transaction);
      await fetchTransactions();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating transaction: $e');
      }
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _dbHelper.deleteTransaction(id);
      await fetchTransactions();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting transaction: $e');
      }
    }
  }

  double getTotalIncome() {
    return _transactions
        .where((t) => t.type == models.TransactionType.income)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double getTotalExpense() {
    return _transactions
        .where((t) => t.type == models.TransactionType.expense)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double getBalance() {
    return getTotalIncome() - getTotalExpense();
  }

  List<models.Transaction> getRecentTransactions({int limit = 5}) {
    final sorted = List<models.Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  Map<String, double> getCategorySpending(models.TransactionType type) {
    final Map<String, double> result = {};

    for (var transaction in _transactions.where((t) => t.type == type)) {
      final category = transaction.category ?? 'Uncategorized';
      result[category] = (result[category] ?? 0) + transaction.amount;
    }

    return result;
  }
}

class AccountProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<models.Account> _accounts = [];
  bool _isLoading = false;

  AccountProvider() {
    fetchAccounts();
  }

  List<models.Account> get accounts => _accounts;
  bool get isLoading => _isLoading;

  Future<void> fetchAccounts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _accounts = await _dbHelper.getAccounts();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching accounts: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAccount(models.Account account) async {
    try {
      await _dbHelper.insertAccount(account);
      await fetchAccounts();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding account: $e');
      }
    }
  }

  Future<void> updateAccount(models.Account account) async {
    try {
      await _dbHelper.updateAccount(account);
      await fetchAccounts();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating account: $e');
      }
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      await _dbHelper.deleteAccount(id);
      await fetchAccounts();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting account: $e');
      }
    }
  }

  double getTotalBalance() {
    return _accounts.fold(0, (sum, account) => sum + account.balance);
  }
}

class CategoryProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<models.Category> _categories = [];
  bool _isLoading = false;

  CategoryProvider() {
    fetchCategories();
  }

  List<models.Category> get categories => _categories;
  List<models.Category> get expenseCategories =>
      _categories.where((c) => c.type == models.TransactionType.expense).toList();
  List<models.Category> get incomeCategories =>
      _categories.where((c) => c.type == models.TransactionType.income).toList();
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _dbHelper.getCategories();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching categories: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
