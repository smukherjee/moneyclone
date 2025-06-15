import 'package:flutter/material.dart';
import 'package:money_clone/ui/theme.dart';
import 'package:money_clone/services/preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(context, 'Currency'),
          _buildCurrencySettings(context),
          const SizedBox(height: 24),

          _buildSectionTitle(context, 'Categories'),
          _buildCategorySettings(context),
          const SizedBox(height: 24),

          _buildSectionTitle(context, 'About'),
          _buildAboutSettings(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildCurrencySettings(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          FutureBuilder<Map<String, String>>(
            future: PreferencesService.getCurrency(),
            builder: (context, snapshot) {
              final currency =
                  snapshot.data ??
                  {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'};
              return ListTile(
                leading: const Icon(
                  Icons.attach_money,
                  color: AppTheme.primaryColor,
                ),
                title: const Text('Currency'),
                subtitle: Text('${currency['name']} (${currency['symbol']})'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showCurrencyDialog(context),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySettings(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.trending_down,
              color: AppTheme.expenseColor,
            ),
            title: const Text('Expense Categories'),
            subtitle: const Text('Manage expense categories'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateToCategoryManagement(context, 'expense'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.trending_up, color: AppTheme.incomeColor),
            title: const Text('Income Categories'),
            subtitle: const Text('Manage income categories'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateToCategoryManagement(context, 'income'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.swap_horiz,
              color: AppTheme.transferColor,
            ),
            title: const Text('Transfer Categories'),
            subtitle: const Text('Manage transfer categories'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateToCategoryManagement(context, 'transfer'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSettings(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info, color: AppTheme.primaryColor),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.privacy_tip,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to privacy policy
            },
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    final currencies = [
      {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
      {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
      {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
      {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
      {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
      {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
      {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    ];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Currency'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  return ListTile(
                    leading: Text(
                      currency['symbol']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(currency['name']!),
                    subtitle: Text(currency['code']!),
                    onTap: () async {
                      await PreferencesService.setCurrency(currency);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Selected ${currency['name']!}'),
                          ),
                        );
                        Navigator.pop(context);
                        // Trigger a rebuild of the settings screen
                        setState(() {});
                      }
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _navigateToCategoryManagement(
    BuildContext context,
    String categoryType,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CategoryManagementScreen(categoryType: categoryType),
      ),
    );
  }
}

class CategoryManagementScreen extends StatefulWidget {
  final String categoryType;

  const CategoryManagementScreen({super.key, required this.categoryType});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _controller = TextEditingController();
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    final categories = await PreferencesService.getCategoriesByType(
      widget.categoryType,
    );
    setState(() {
      _categories = categories;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryTypeTitle =
        widget.categoryType == 'expense'
            ? 'Expense Categories'
            : widget.categoryType == 'income'
            ? 'Income Categories'
            : 'Transfer Categories';

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTypeTitle),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Add category section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      hintText: 'Enter new category name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80, // Fixed width for the button
                  height: 56, // Match the TextField height
                  child: ElevatedButton(
                    onPressed: _addCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Categories list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      _getCategoryIcon(widget.categoryType),
                      color: _getCategoryColor(widget.categoryType),
                    ),
                    title: Text(category),
                    trailing:
                        category !=
                                'Other' // Don't allow deleting 'Other'
                            ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCategory(index),
                            )
                            : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryType) {
    switch (categoryType) {
      case 'expense':
        return Icons.trending_down;
      case 'income':
        return Icons.trending_up;
      case 'transfer':
        return Icons.swap_horiz;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String categoryType) {
    switch (categoryType) {
      case 'expense':
        return AppTheme.expenseColor;
      case 'income':
        return AppTheme.incomeColor;
      case 'transfer':
        return AppTheme.transferColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  void _addCategory() async {
    final categoryName = _controller.text.trim();
    if (categoryName.isNotEmpty && !_categories.contains(categoryName)) {
      setState(() {
        _categories.insert(
          _categories.length - 1,
          categoryName,
        ); // Insert before 'Other'
      });
      _controller.clear();

      // Save to preferences
      await PreferencesService.setCategoriesByType(
        widget.categoryType,
        _categories,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added category: $categoryName')),
        );
      }
    } else if (_categories.contains(categoryName)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Category already exists')));
    }
  }

  void _deleteCategory(int index) {
    final categoryName = _categories[index];
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Category'),
            content: Text('Are you sure you want to delete "$categoryName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  setState(() {
                    _categories.removeAt(index);
                  });
                  Navigator.pop(context);

                  // Save to preferences
                  await PreferencesService.setCategoriesByType(
                    widget.categoryType,
                    _categories,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Deleted category: $categoryName'),
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
