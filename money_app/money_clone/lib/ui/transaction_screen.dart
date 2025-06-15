import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_clone/data/database_helper.dart';
import 'package:money_clone/data/models.dart';
import 'package:money_clone/logic/providers.dart';
import 'package:money_clone/services/preferences_service.dart';
import 'package:money_clone/ui/theme.dart';
import 'package:money_clone/ui/widgets.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildCategoryFilter(context),

          // Transactions list
          Expanded(child: _buildTransactionList(context)),
        ],
      ),
      // We don't need a FloatingActionButton here as it's already handled by MainScreen
      // through the NavigationService
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final currentFilter = provider.filter;

        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              CategoryChip(
                name: 'All',
                isSelected: currentFilter == null,
                onTap: () {
                  provider.clearFilter();
                },
              ),
              CategoryChip(
                name: 'Income',
                isSelected: currentFilter == TransactionType.income,
                onTap: () {
                  provider.setFilter(TransactionType.income);
                },
              ),
              CategoryChip(
                name: 'Expense',
                isSelected: currentFilter == TransactionType.expense,
                onTap: () {
                  provider.setFilter(TransactionType.expense);
                },
              ),
              CategoryChip(
                name: 'Transfer',
                isSelected: currentFilter == TransactionType.transfer,
                onTap: () {
                  provider.setFilter(TransactionType.transfer);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final transactions = provider.transactions;
        final filterType = provider.filter;

        if (transactions.isEmpty) {
          String message = 'No transactions found';
          if (filterType != null) {
            message =
                'No ${filterType.toString().split('.').last} transactions found';
          }

          return EmptyStateWidget(
            message: message,
            icon: Icons.receipt_long_outlined,
            onActionPressed: () {
              _showAddTransactionDialog(context);
            },
            actionLabel: 'Add Transaction',
          );
        }

        // Sort transactions by date (newest first)
        final sortedTransactions = List<Transaction>.from(transactions)
          ..sort((a, b) => b.date.compareTo(a.date));

        return ListView.builder(
          itemCount: sortedTransactions.length,
          itemBuilder: (context, index) {
            final transaction = sortedTransactions[index];

            // Add date header if this is a new date
            if (index == 0 ||
                !_isSameDay(
                  sortedTransactions[index - 1].date,
                  transaction.date,
                )) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateHeader(context, transaction.date),
                  TransactionListItem(
                    transaction: transaction,
                    onTap: () {
                      _showAddTransactionDialog(context, transaction);
                    },
                  ),
                ],
              );
            }

            return TransactionListItem(
              transaction: transaction,
              onTap: () {
                _showAddTransactionDialog(context, transaction);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final now = DateTime.now();

    String headerText;
    if (_isSameDay(date, now)) {
      headerText = 'Today';
    } else if (_isSameDay(date, DateTime(now.year, now.month, now.day - 1))) {
      headerText = 'Yesterday';
    } else {
      headerText = dateFormat.format(date);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        headerText,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showAddTransactionDialog(
    BuildContext context, [
    Transaction? transactionToEdit,
  ]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              AddTransactionSheet(transactionToEdit: transactionToEdit),
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

  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String? _selectedAccountId;
  String? _selectedToAccountId; // For transfers
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  bool get _isEditMode => widget.transactionToEdit != null;

  @override
  void initState() {
    super.initState();
    // Accounts should already be loaded from app initialization
    // But if not, they will be fetched by the account selector widget

    // Populate fields if editing an existing transaction
    if (_isEditMode) {
      final transaction = widget.transactionToEdit!;
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toString();
      _descriptionController.text = transaction.description ?? '';
      _selectedType = transaction.type;
      _selectedDate = transaction.date;
      _selectedCategory = transaction.category;
      _selectedAccountId = transaction.accountId;
      _selectedPaymentMethod = transaction.paymentMethod;

      // For transfer transactions, we need to handle the destination account
      // Since the current model doesn't store destination account directly,
      // we'll leave _selectedToAccountId as null and let the user select it again
      if (transaction.type == TransactionType.transfer) {
        _selectedToAccountId =
            null; // User will need to reselect the destination
      }
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isEditMode ? 'Edit Transaction' : 'Add Transaction',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),

                // Transaction type selector
                _buildTypeSelector(),
                const SizedBox(height: 16),

                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter transaction title',
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
                    hintText: '0.00',
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

                // Date picker
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category selector (simplified)
                _buildCategorySelector(),
                const SizedBox(height: 16),

                // Payment method selector (not shown for transfers)
                if (_selectedType != TransactionType.transfer) ...[
                  _buildPaymentMethodSelector(),
                  const SizedBox(height: 16),
                ],

                // Account selector(s)
                _selectedType == TransactionType.transfer
                    ? _buildTransferAccountSelectors()
                    : _buildAccountSelector(),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Enter additional details',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Save button
                ElevatedButton(
                  onPressed: _saveTransaction,
                  child: Text(
                    _isEditMode ? 'Update Transaction' : 'Save Transaction',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeButton(
            title: 'Expense',
            icon: Icons.arrow_upward,
            type: TransactionType.expense,
            color: AppTheme.expenseColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTypeButton(
            title: 'Income',
            icon: Icons.arrow_downward,
            type: TransactionType.income,
            color: AppTheme.incomeColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTypeButton(
            title: 'Transfer',
            icon: Icons.swap_horiz,
            type: TransactionType.transfer,
            color: AppTheme.transferColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required String title,
    required IconData icon,
    required TransactionType type,
    required Color color,
  }) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () {
        setState(() {
          final previousType = _selectedType;
          _selectedType = type;

          // Reset category selection when transaction type changes
          // because different types have different category lists
          if (previousType != type) {
            _selectedCategory = null;

            // Reset transfer-specific fields when switching away from transfer
            if (previousType == TransactionType.transfer) {
              _selectedToAccountId = null;
            }
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withAlpha((0.1 * 255).round())
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
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
        // If not valid, use null for the dropdown value
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

  Widget _buildPaymentMethodSelector() {
    return DropdownButtonFormField<PaymentMethod>(
      decoration: const InputDecoration(
        labelText: 'Payment Method',
        prefixIcon: Icon(Icons.payment),
      ),
      value: _selectedPaymentMethod,
      items:
          PaymentMethod.values
              .map(
                (method) => DropdownMenuItem<PaymentMethod>(
                  value: method,
                  child: Text(_getPaymentMethodName(method)),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPaymentMethod = value;
          });
        }
      },
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  Widget _buildAccountSelector() {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        if (accountProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final accounts = accountProvider.accounts;

        // If no accounts are loaded, trigger a fetch
        if (accounts.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            accountProvider.fetchAccounts();
          });
          return const Center(child: CircularProgressIndicator());
        }

        // Validate that the selected account ID exists in the current accounts
        final validAccountIds = accounts.map((account) => account.id).toSet();
        String? displayValue = _selectedAccountId;

        if (_selectedAccountId != null &&
            !validAccountIds.contains(_selectedAccountId)) {
          // If the selected account doesn't exist, reset to null
          displayValue = null;
        }

        // Set default account if none selected or invalid
        if (displayValue == null && accounts.isNotEmpty) {
          displayValue = accounts.first.id;
          // Update the state on next frame to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedAccountId = accounts.first.id;
              });
            }
          });
        }

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Account',
            prefixIcon: Icon(Icons.account_balance_wallet),
          ),
          value: displayValue,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an account';
            }
            return null;
          },
          items:
              accounts
                  .map(
                    (account) => DropdownMenuItem<String>(
                      value: account.id,
                      child: Text(
                        '${account.name} (\$${account.balance.toStringAsFixed(2)})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedAccountId = value;
              });
            }
          },
        );
      },
    );
  }

  Widget _buildTransferAccountSelectors() {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        if (accountProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final accounts = accountProvider.accounts;

        if (accounts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Validate that the selected account IDs exist in the current accounts
        final validAccountIds = accounts.map((account) => account.id).toSet();

        String? fromDisplayValue = _selectedAccountId;
        String? toDisplayValue = _selectedToAccountId;

        if (_selectedAccountId != null &&
            !validAccountIds.contains(_selectedAccountId)) {
          fromDisplayValue = null;
        }

        if (_selectedToAccountId != null &&
            !validAccountIds.contains(_selectedToAccountId)) {
          toDisplayValue = null;
        }

        // Set default accounts if none selected
        if (fromDisplayValue == null && accounts.isNotEmpty) {
          fromDisplayValue = accounts.first.id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedAccountId = accounts.first.id;
              });
            }
          });
        }

        return Column(
          children: [
            // From Account selector
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'From Account',
                prefixIcon: Icon(Icons.arrow_upward),
              ),
              value: fromDisplayValue,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a from account';
                }
                return null;
              },
              items:
                  accounts
                      .map(
                        (account) => DropdownMenuItem<String>(
                          value: account.id,
                          child: Text(
                            '${account.name} (\$${account.balance.toStringAsFixed(2)})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedAccountId = value;
                    // Reset to account if it's the same as from account
                    if (_selectedToAccountId == value) {
                      _selectedToAccountId = null;
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // To Account selector
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'To Account',
                prefixIcon: Icon(Icons.arrow_downward),
              ),
              value: toDisplayValue,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a to account';
                }
                if (value == _selectedAccountId) {
                  return 'To account must be different from from account';
                }
                return null;
              },
              items:
                  accounts
                      .where(
                        (account) => account.id != _selectedAccountId,
                      ) // Exclude the from account
                      .map(
                        (account) => DropdownMenuItem<String>(
                          value: account.id,
                          child: Text(
                            '${account.name} (\$${account.balance.toStringAsFixed(2)})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedToAccountId = value;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final accountProvider = Provider.of<AccountProvider>(
        context,
        listen: false,
      );

      if (_selectedType == TransactionType.transfer) {
        // Handle transfers specially - create two transactions
        if (_selectedToAccountId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a destination account'),
            ),
          );
          return;
        }

        final transferAmount = double.parse(_amountController.text);
        final transferDescription =
            _descriptionController.text.isEmpty
                ? 'Transfer from account to account'
                : _descriptionController.text;

        if (_isEditMode) {
          // For editing transfers, delete the old transaction and create new ones
          // Note: If original was expense/income type, just delete it
          // If original was transfer type, try to find and delete the partner transaction too
          await provider.deleteTransaction(widget.transactionToEdit!.id);

          // TODO: In the future, we could implement logic to find and delete
          // the partner transaction if the original was part of a transfer pair
        }

        // Create outgoing transaction (from source account)
        final outgoingTransaction = Transaction(
          id: const Uuid().v4(),
          title: 'Transfer to ${await _getAccountName(_selectedToAccountId!)}',
          amount: transferAmount,
          date: _selectedDate,
          type: TransactionType.expense, // Money leaving the source account
          category: _selectedCategory ?? 'Account Transfer',
          description: transferDescription,
          paymentMethod: PaymentMethod.bankTransfer,
          accountId: _selectedAccountId!,
        );

        // Create incoming transaction (to destination account)
        final incomingTransaction = Transaction(
          id: const Uuid().v4(),
          title: 'Transfer from ${await _getAccountName(_selectedAccountId!)}',
          amount: transferAmount,
          date: _selectedDate,
          type:
              TransactionType.income, // Money entering the destination account
          category: _selectedCategory ?? 'Account Transfer',
          description: transferDescription,
          paymentMethod: PaymentMethod.bankTransfer,
          accountId: _selectedToAccountId!,
        );

        // Add both transactions
        await provider.addTransaction(outgoingTransaction);
        await provider.addTransaction(incomingTransaction);
      } else {
        // Handle regular income/expense transactions
        String accountId = _selectedAccountId ?? '';
        if (accountId.isEmpty) {
          final dbHelper = DatabaseHelper();
          accountId = await dbHelper.getDefaultAccountId();
        }

        final transaction = Transaction(
          id: _isEditMode ? widget.transactionToEdit!.id : const Uuid().v4(),
          title: _titleController.text,
          amount: double.parse(_amountController.text),
          date: _selectedDate,
          type: _selectedType,
          category: _selectedCategory,
          description:
              _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
          paymentMethod: _selectedPaymentMethod,
          accountId: accountId,
        );

        if (_isEditMode) {
          await provider.updateTransaction(transaction);
        } else {
          await provider.addTransaction(transaction);
        }
      }

      // Refresh account balances since transactions affect account balances
      await accountProvider.fetchAccounts();

      Navigator.pop(context);
    }
  }

  // Helper method to get account name by ID
  Future<String> _getAccountName(String accountId) async {
    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );
    final account = accountProvider.accounts.firstWhere(
      (acc) => acc.id == accountId,
      orElse:
          () => Account(
            id: '',
            name: 'Unknown Account',
            balance: 0,
            type: AccountType.other,
          ),
    );
    return account.name;
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
}
