import 'package:flutter/foundation.dart';
import 'package:money_clone/data/database_helper.dart';
import 'package:money_clone/data/models.dart' as models;
import 'package:money_clone/utils/logging_service.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final LoggingService _logger = LoggingService();
  List<models.Transaction> _transactions = [];
  bool _isLoading = false;
  models.TransactionType? _filter;

  TransactionProvider() {
    fetchTransactions();
  }

  List<models.Transaction> get transactions =>
      _filter == null
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
      _logger.info('Successfully fetched ${_transactions.length} transactions');
    } catch (e) {
      _logger.error('Error fetching transactions', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(models.Transaction transaction) async {
    try {
      await _dbHelper.insertTransaction(transaction);
      _logger.info('Transaction added successfully: ${transaction.title}');
      await fetchTransactions();
    } catch (e) {
      _logger.error('Error adding transaction', e);
    }
  }

  Future<void> updateTransaction(models.Transaction transaction) async {
    try {
      await _dbHelper.updateTransaction(transaction);
      _logger.info('Transaction updated successfully: ${transaction.title}');
      await fetchTransactions();
    } catch (e) {
      _logger.error('Error updating transaction', e);
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _dbHelper.deleteTransaction(id);
      _logger.info('Transaction deleted successfully');
      await fetchTransactions();
    } catch (e) {
      _logger.error('Error deleting transaction', e);
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
    // Sort transactions by date in descending order and take the most recent ones
    final sortedTransactions = List<models.Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedTransactions.take(limit).toList();
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
  final LoggingService _logger = LoggingService();

  List<models.Account> _accounts = [];
  bool _isLoading = false;

  List<models.Account> get accounts => _accounts;
  bool get isLoading => _isLoading;

  Future<void> fetchAccounts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _accounts = await _dbHelper.getAccounts();
      _logger.info('Successfully fetched ${_accounts.length} accounts');
    } catch (e) {
      _logger.error('Error fetching accounts', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAccount(models.Account account) async {
    try {
      await _dbHelper.insertAccount(account);
      _logger.info('Account added successfully: ${account.name}');
      await fetchAccounts();
    } catch (e) {
      _logger.error('Error adding account', e);
    }
  }

  Future<void> updateAccount(models.Account account) async {
    try {
      await _dbHelper.updateAccount(account);
      _logger.info('Account updated successfully: ${account.name}');
      await fetchAccounts();
    } catch (e) {
      _logger.error('Error updating account', e);
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      await _dbHelper.deleteAccount(id);
      _logger.info('Account deleted successfully');
      await fetchAccounts();
    } catch (e) {
      _logger.error('Error deleting account', e);
    }
  }

  models.Account? getAccountById(String id) {
    try {
      return _accounts.firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }

  double getTotalBalance() {
    return _accounts.fold(0.0, (sum, account) => sum + account.balance);
  }
}

class CategoryProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final LoggingService _logger = LoggingService();
  List<models.Category> _categories = [];
  bool _isLoading = false;

  CategoryProvider() {
    fetchCategories();
  }

  List<models.Category> get categories => _categories;
  List<models.Category> get expenseCategories =>
      _categories
          .where((c) => c.type == models.TransactionType.expense)
          .toList();
  List<models.Category> get incomeCategories =>
      _categories
          .where((c) => c.type == models.TransactionType.income)
          .toList();
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _dbHelper.getCategories();
      _logger.info('Successfully fetched ${_categories.length} categories');
    } catch (e) {
      _logger.error('Error fetching categories', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
