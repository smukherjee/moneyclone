import 'package:money_clone/data/models.dart';
import 'package:money_clone/utils/compute_helper.dart';
import 'package:money_clone/utils/transaction_list_optimizer.dart';

/// A utility class to optimize home screen operations
class HomeScreenOptimizer {
  // Cache for category spending data
  static final Map<String, Map<String, double>> _categorySpendingCache = {};

  /// Get category spending with efficient caching for home screen
  static Map<String, double> getCategorySpending(
    List<Transaction> transactions,
    TransactionType type,
    String cacheKey,
  ) {
    // Check cache first
    if (_categorySpendingCache.containsKey(cacheKey)) {
      return _categorySpendingCache[cacheKey]!;
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
    String cacheKey,
  ) async {
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

  /// Get recent transactions efficiently
  static List<Transaction> getRecentTransactions(
    List<Transaction> transactions,
    int limit,
  ) {
    // Sort transactions by date
    final sorted = TransactionListOptimizer.getSortedTransactions(
      transactions,
      'recent_${transactions.length}',
    );

    // Take only the requested number of transactions
    return sorted.take(limit).toList();
  }

  /// Get sorted category spending entries
  static List<MapEntry<String, double>> getSortedCategorySpending(
    Map<String, double> categorySpending,
  ) {
    final entries = categorySpending.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }
}
