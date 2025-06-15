import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static const String _currencyKey = 'selected_currency';
  static const String _expenseCategoriesKey = 'expense_categories';
  static const String _incomeCategoriesKey = 'income_categories';
  static const String _transferCategoriesKey = 'transfer_categories';

  // Default categories
  static const List<String> _defaultExpenseCategories = [
    'Food & Dining',
    'Shopping',
    'Housing',
    'Transportation',
    'Entertainment',
    'Health & Fitness',
    'Other',
  ];

  static const List<String> _defaultIncomeCategories = [
    'Salary',
    'Business',
    'Investments',
    'Rental Income',
    'Gifts',
    'Other',
  ];

  static const List<String> _defaultTransferCategories = [
    'Account Transfer',
    'Savings Transfer',
    'Investment Transfer',
    'Other',
  ];

  static const Map<String, String> _defaultCurrency = {
    'code': 'USD',
    'symbol': '\$',
    'name': 'US Dollar',
  };

  // Currency methods
  static Future<Map<String, String>> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final currencyJson = prefs.getString(_currencyKey);
    if (currencyJson != null) {
      return Map<String, String>.from(json.decode(currencyJson));
    }
    return _defaultCurrency;
  }

  static Future<void> setCurrency(Map<String, String> currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, json.encode(currency));
  }

  // Expense categories methods
  static Future<List<String>> getExpenseCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categories = prefs.getStringList(_expenseCategoriesKey);
    return categories ?? List.from(_defaultExpenseCategories);
  }

  static Future<void> setExpenseCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_expenseCategoriesKey, categories);
  }

  // Income categories methods
  static Future<List<String>> getIncomeCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categories = prefs.getStringList(_incomeCategoriesKey);
    return categories ?? List.from(_defaultIncomeCategories);
  }

  static Future<void> setIncomeCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_incomeCategoriesKey, categories);
  }

  // Transfer categories methods
  static Future<List<String>> getTransferCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categories = prefs.getStringList(_transferCategoriesKey);
    return categories ?? List.from(_defaultTransferCategories);
  }

  static Future<void> setTransferCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_transferCategoriesKey, categories);
  }

  // Helper method to get categories by type
  static Future<List<String>> getCategoriesByType(String type) async {
    switch (type) {
      case 'expense':
        return getExpenseCategories();
      case 'income':
        return getIncomeCategories();
      case 'transfer':
        return getTransferCategories();
      default:
        return [];
    }
  }

  // Helper method to set categories by type
  static Future<void> setCategoriesByType(
    String type,
    List<String> categories,
  ) async {
    switch (type) {
      case 'expense':
        return setExpenseCategories(categories);
      case 'income':
        return setIncomeCategories(categories);
      case 'transfer':
        return setTransferCategories(categories);
    }
  }
}
