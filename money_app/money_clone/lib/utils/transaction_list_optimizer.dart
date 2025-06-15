import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:money_clone/data/models.dart';
import 'package:money_clone/utils/compute_helper.dart';

/// A utility class to help with optimizing transaction lists
class TransactionListOptimizer {
  // Cache for sorted transactions
  static final Map<String, List<Transaction>> _sortedTransactionsCache = {};

  /// Get sorted transactions with caching
  static List<Transaction> getSortedTransactions(
    List<Transaction> transactions,
    String cacheKey,
  ) {
    // Check cache first
    if (_sortedTransactionsCache.containsKey(cacheKey)) {
      return _sortedTransactionsCache[cacheKey]!;
    }

    // Sort transactions
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Cache result
    _sortedTransactionsCache[cacheKey] = sorted;

    return sorted;
  }

  /// Clear the cache when data changes
  static void clearCache() {
    _sortedTransactionsCache.clear();
  }

  /// Generate a cache key based on filter type
  static String generateCacheKey(TransactionType? filterType) {
    return filterType?.toString() ?? 'all';
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Group transactions by date for more efficient rendering
  static Future<Map<DateTime, List<Transaction>>> groupTransactionsByDate(
    List<Transaction> transactions,
  ) async {
    // Use compute for larger lists
    if (transactions.length > 100) {
      return ComputeHelper.runAsync<
        List<Transaction>,
        Map<DateTime, List<Transaction>>
      >(_groupTransactionsByDateBackground, transactions);
    }

    // For smaller lists, just do it synchronously
    return _groupTransactionsByDateSync(transactions);
  }

  /// Group transactions by date synchronously
  static Map<DateTime, List<Transaction>> _groupTransactionsByDateSync(
    List<Transaction> transactions,
  ) {
    final Map<DateTime, List<Transaction>> result = {};

    for (var transaction in transactions) {
      // Normalize the date to remove time component
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      if (!result.containsKey(date)) {
        result[date] = [];
      }

      result[date]!.add(transaction);
    }

    return result;
  }

  /// Background computation for grouping transactions
  static Map<DateTime, List<Transaction>> _groupTransactionsByDateBackground(
    List<Transaction> transactions,
  ) {
    // This is now handled by ComputeHelper._isolateWrapper
    return _groupTransactionsByDateSync(transactions);
  }
}
