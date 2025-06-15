import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_clone/data/models.dart';
import 'package:money_clone/services/preferences_service.dart';
import 'package:money_clone/ui/theme.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionListItem({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category icon or transaction type indicator
              _buildTransactionIcon(),
              const SizedBox(width: 16),

              // Title and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(transaction.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (transaction.description != null &&
                        transaction.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          transaction.description!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),

              // Amount
              Text(
                _formatAmount(transaction.amount, transaction.type),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _getAmountColor(transaction.type),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionIcon() {
    Color backgroundColor;
    IconData iconData;

    switch (transaction.type) {
      case TransactionType.income:
        backgroundColor = AppTheme.incomeColor.withAlpha((0.2 * 255).round());
        iconData = Icons.arrow_downward;
        break;
      case TransactionType.expense:
        backgroundColor = AppTheme.expenseColor.withAlpha((0.2 * 255).round());
        iconData = Icons.arrow_upward;
        break;
      case TransactionType.transfer:
        backgroundColor = AppTheme.transferColor.withAlpha((0.2 * 255).round());
        iconData = Icons.swap_horiz;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: _getAmountColor(transaction.type), size: 20),
    );
  }

  String _formatAmount(double amount, TransactionType type) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    return currencyFormat.format(amount);
  }

  Color _getAmountColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return AppTheme.incomeColor;
      case TransactionType.expense:
        return AppTheme.expenseColor;
      case TransactionType.transfer:
        return AppTheme.transferColor;
    }
  }
}

class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expenses;
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expenses,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppTheme.primaryColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Balance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withAlpha((0.8 * 255).round()),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(balance),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Income section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_downward,
                              color: Colors.white.withAlpha(
                                (0.8 * 255).round(),
                              ),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Income',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withAlpha(
                                  (0.8 * 255).round(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(income),
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.white.withAlpha((0.3 * 255).round()),
                  ),

                  // Expenses section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                color: Colors.white.withAlpha(
                                  (0.8 * 255).round(),
                                ),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Expenses',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withAlpha(
                                    (0.8 * 255).round(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat.format(expenses),
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPressed;

  const SectionHeader({super.key, required this.title, this.onSeeAllPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (onSeeAllPressed != null)
            TextButton(
              onPressed: onSeeAllPressed,
              child: const Text('See All'),
            ),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.message,
    required this.icon,
    this.onActionPressed,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            if (onActionPressed != null && actionLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: ElevatedButton(
                  onPressed: onActionPressed,
                  child: Text(actionLabel!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AddTransactionSheet extends StatefulWidget {
  final Transaction? transactionToEdit;

  const AddTransactionSheet({super.key, this.transactionToEdit});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategory;

  bool get _isEditMode => widget.transactionToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final transaction = widget.transactionToEdit!;
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toString();
      _descriptionController.text = transaction.description ?? '';
      _selectedType = transaction.type;
      _selectedCategory = transaction.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      _isEditMode ? 'Edit Transaction' : 'Add Transaction',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),

                    // Transaction type selector
                    _buildTransactionTypeSelector(),
                    const SizedBox(height: 16),

                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Amount field
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category selector
                    _buildCategorySelector(),
                    const SizedBox(height: 16),

                    // Account selector (changes based on transaction type)
                    if (_selectedType == TransactionType.transfer)
                      _buildTransferAccountSelectors()
                    else
                      _buildAccountSelector(),
                    const SizedBox(height: 16),

                    // Payment method selector (only for non-transfers)
                    if (_selectedType != TransactionType.transfer) ...[
                      _buildPaymentMethodSelector(),
                      const SizedBox(height: 16),
                    ],

                    // Date selector
                    _buildDateSelector(),
                    const SizedBox(height: 16),

                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveTransaction,
                        child: Text(
                          _isEditMode
                              ? 'Update Transaction'
                              : 'Save Transaction',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // All the same helper methods from transaction_screen.dart would go here
  // For brevity, I'll include the key ones needed for categories

  Widget _buildTransactionTypeSelector() {
    return SegmentedButton<TransactionType>(
      segments: const [
        ButtonSegment<TransactionType>(
          value: TransactionType.income,
          label: Text('Income'),
          icon: Icon(Icons.add_circle, color: Colors.green),
        ),
        ButtonSegment<TransactionType>(
          value: TransactionType.expense,
          label: Text('Expense'),
          icon: Icon(Icons.remove_circle, color: Colors.red),
        ),
        ButtonSegment<TransactionType>(
          value: TransactionType.transfer,
          label: Text('Transfer'),
          icon: Icon(Icons.swap_horiz, color: Colors.blue),
        ),
      ],
      selected: {_selectedType},
      onSelectionChanged: (Set<TransactionType> newSelection) {
        setState(() {
          _selectedType = newSelection.first;
          _selectedCategory = null; // Reset category when type changes
        });
      },
    );
  }

  Widget _buildCategorySelector() {
    return FutureBuilder<List<String>>(
      future: _getCategoriesForType(_selectedType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category),
            ),
            items: const [],
            onChanged: null,
          );
        }

        final categories = snapshot.data ?? [];
        final categoryItems =
            categories
                .map(
                  (category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ),
                )
                .toList();

        final validCategories = categoryItems.map((item) => item.value).toSet();

        // Ensure selected category is valid for current transaction type
        String? displayValue = _selectedCategory;
        if (_selectedCategory != null &&
            !validCategories.contains(_selectedCategory)) {
          displayValue = null;
        }

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Category',
            prefixIcon: Icon(Icons.category),
          ),
          value: displayValue,
          items: categoryItems,
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
        );
      },
    );
  }

  // Method to get categories for a specific transaction type from preferences
  Future<List<String>> _getCategoriesForType(TransactionType type) async {
    switch (type) {
      case TransactionType.income:
        return await PreferencesService.getIncomeCategories();
      case TransactionType.expense:
        return await PreferencesService.getExpenseCategories();
      case TransactionType.transfer:
        return await PreferencesService.getTransferCategories();
    }
  }

  // Placeholder methods - you'd need to implement these similar to transaction_screen.dart
  Widget _buildAccountSelector() {
    return const Text('Account selector placeholder');
  }

  Widget _buildTransferAccountSelectors() {
    return const Text('Transfer account selectors placeholder');
  }

  Widget _buildPaymentMethodSelector() {
    return const Text('Payment method selector placeholder');
  }

  Widget _buildDateSelector() {
    return const Text('Date selector placeholder');
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      // Implement save logic
      Navigator.pop(context);
    }
  }
}
