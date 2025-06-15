import 'package:flutter/foundation.dart';
import 'package:money_clone/data/models.dart';
import 'package:money_clone/utils/compute_helper.dart';

/// A utility class to optimize account operations
class AccountOptimizer {
  // Cache for account balance calculations
  static final Map<String, double> _accountBalanceCache = {};

  /// Get total balance with caching
  static double getTotalBalance(List<Account> accounts, String cacheKey) {
    // Check cache first
    if (_accountBalanceCache.containsKey(cacheKey)) {
      return _accountBalanceCache[cacheKey]!;
    }

    // Calculate total balance
    double total = 0;
    for (var account in accounts) {
      total += account.balance;
    }

    // Cache result
    _accountBalanceCache[cacheKey] = total;

    return total;
  }

  /// Calculate total balance asynchronously for large datasets
  static Future<double> getTotalBalanceAsync(
    List<Account> accounts,
    String cacheKey,
  ) async {
    // Check cache first
    if (_accountBalanceCache.containsKey(cacheKey)) {
      return _accountBalanceCache[cacheKey]!;
    }

    // Calculate in background
    final result = await ComputeHelper.runAsync<List<Account>, double>(
      _calculateTotalBalanceBackground,
      accounts,
    );

    // Cache result
    _accountBalanceCache[cacheKey] = result;

    return result;
  }

  /// Clear cache when data changes
  static void clearCache() {
    _accountBalanceCache.clear();
  }

  /// Background computation for total balance
  static double _calculateTotalBalanceBackground(List<Account> accounts) {
    // This is now handled by ComputeHelper._isolateWrapper
    double total = 0;
    for (var account in accounts) {
      total += account.balance;
    }
    return total;
  }

  /// Get accounts filtered by account type
  static List<Account> getAccountsByType(
    List<Account> accounts,
    AccountType type,
  ) {
    final result = <Account>[];
    for (var account in accounts) {
      if (account.type == type) {
        result.add(account);
      }
    }
    return result;
  }

  /// Get accounts with positive balance
  static List<Account> getAccountsWithPositiveBalance(List<Account> accounts) {
    final result = <Account>[];
    for (var account in accounts) {
      if (account.balance > 0) {
        result.add(account);
      }
    }
    return result;
  }

  /// Get accounts with negative balance
  static List<Account> getAccountsWithNegativeBalance(List<Account> accounts) {
    final result = <Account>[];
    for (var account in accounts) {
      if (account.balance < 0) {
        result.add(account);
      }
    }
    return result;
  }

  /// Sort accounts by balance (descending)
  static List<Account> sortAccountsByBalance(List<Account> accounts) {
    final result = List<Account>.from(accounts);
    result.sort((a, b) => b.balance.compareTo(a.balance));
    return result;
  }

  /// Sort accounts by name
  static List<Account> sortAccountsByName(List<Account> accounts) {
    final result = List<Account>.from(accounts);
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }
}
