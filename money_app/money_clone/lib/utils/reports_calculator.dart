import 'package:flutter/foundation.dart';
import 'package:money_clone/data/models.dart';
import 'package:money_clone/utils/compute_helper.dart';

/// A utility class to optimize report calculations
class ReportsCalculator {
  // Cache for category spending calculations
  static final Map<String, Map<String, double>> _categorySpendingCache = {};

  /// Get category spending with caching
  static Map<String, double> getCategorySpending(
    List<Transaction> transactions,
    TransactionType type,
    String period,
  ) {
    final cacheKey = '${type.toString()}_$period';

    // Check cache first
    if (_categorySpendingCache.containsKey(cacheKey)) {
      return _categorySpendingCache[cacheKey]!;
    }

    // If we have a lot of transactions, use compute
    if (transactions.length > 100) {
      return {}; // We'll handle this asynchronously instead
    }

    // Calculate category spending
    final result = _calculateCategorySpendingSync(transactions, type);

    // Cache result
    _categorySpendingCache[cacheKey] = result;

    return result;
  }

  /// Calculate category spending asynchronously for large datasets
  static Future<Map<String, double>> getCategorySpendingAsync(
    List<Transaction> transactions,
    TransactionType type,
    String period,
  ) async {
    final cacheKey = '${type.toString()}_$period';

    // Check cache first
    if (_categorySpendingCache.containsKey(cacheKey)) {
      return _categorySpendingCache[cacheKey]!;
    }

    // Calculate in background
    final result =
        await ComputeHelper.runAsync<Map<String, dynamic>, Map<String, double>>(
          _calculateCategorySpendingBackground,
          {'transactions': transactions, 'type': type.toString()},
        );

    // Cache result
    _categorySpendingCache[cacheKey] = result;

    return result;
  }

  /// Clear cache when data changes
  static void clearCache() {
    _categorySpendingCache.clear();
  }

  /// Calculate category spending synchronously
  static Map<String, double> _calculateCategorySpendingSync(
    List<Transaction> transactions,
    TransactionType type,
  ) {
    final Map<String, double> result = {};

    for (var transaction in transactions) {
      if (transaction.type == type) {
        final category = transaction.category ?? 'Uncategorized';
        result[category] = (result[category] ?? 0) + transaction.amount;
      }
    }

    return result;
  }

  /// Background computation for category spending
  static Map<String, double> _calculateCategorySpendingBackground(
    Map<String, dynamic> params,
  ) {
    // This is now handled by ComputeHelper._isolateWrapper
    final transactions = params['transactions'] as List<Transaction>;
    final typeStr = params['type'] as String;
    final type = TransactionType.values.firstWhere(
      (t) => t.toString() == typeStr,
      orElse: () => TransactionType.expense,
    );

    return _calculateCategorySpendingSync(transactions, type);
  }

  /// Get sorted category spending entries
  static List<MapEntry<String, double>> getSortedCategorySpending(
    Map<String, double> categorySpending,
  ) {
    final entries = categorySpending.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Get total for a transaction type
  static double getTotal(List<Transaction> transactions, TransactionType type) {
    double total = 0;
    for (var transaction in transactions) {
      if (transaction.type == type) {
        total += transaction.amount;
      }
    }
    return total;
  }

  /// Get transaction data for a specific time period
  static List<Transaction> getTransactionsForPeriod(
    List<Transaction> allTransactions,
    String period,
  ) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        // Start from the beginning of the current week (Sunday or Monday depending on locale)
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Last 3 Months':
        startDate = DateTime(now.year, now.month - 2, 1);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        // Default to this month
        startDate = DateTime(now.year, now.month, 1);
    }

    return allTransactions.where((t) => t.date.isAfter(startDate)).toList();
  }
}
