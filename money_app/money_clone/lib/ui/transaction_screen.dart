import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_clone/data/models.dart';
import 'package:money_clone/logic/providers.dart';
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
          Expanded(
            child: _buildTransactionList(context),          ),
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
            message = 'No ${filterType.toString().split('.').last} transactions found';
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
            if (index == 0 || !_isSameDay(sortedTransactions[index - 1].date, transaction.date)) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateHeader(context, transaction.date),
                  TransactionListItem(
                    transaction: transaction,
                    onTap: () {
                      // Navigate to transaction details
                    },
                  ),
                ],
              );
            }
            
            return TransactionListItem(
              transaction: transaction,
              onTap: () {
                // Navigate to transaction details
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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showAddTransactionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionSheet(),
    );
  }
}

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

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
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

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
                  'Add Transaction',
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
                
                // Payment method selector
                _buildPaymentMethodSelector(),
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
                  child: const Text('Save Transaction'),
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
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
            ),
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
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Icons.category),
      ),
      value: _selectedCategory,
      items: _getCategoryItems(),
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
  }

  List<DropdownMenuItem<String>> _getCategoryItems() {
    // Normally we'd get these from the CategoryProvider
    final List<String> categories = _selectedType == TransactionType.income
        ? ['Salary', 'Business', 'Investments', 'Rental Income', 'Gifts', 'Other']
        : ['Food & Dining', 'Shopping', 'Housing', 'Transportation', 'Entertainment', 'Health & Fitness', 'Other'];
    
    return categories
        .map((category) => DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            ))
        .toList();
  }

  Widget _buildPaymentMethodSelector() {
    return DropdownButtonFormField<PaymentMethod>(
      decoration: const InputDecoration(
        labelText: 'Payment Method',
        prefixIcon: Icon(Icons.payment),
      ),
      value: _selectedPaymentMethod,
      items: PaymentMethod.values
          .map((method) => DropdownMenuItem<PaymentMethod>(
                value: method,
                child: Text(_getPaymentMethodName(method)),
              ))
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

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        id: const Uuid().v4(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        type: _selectedType,
        category: _selectedCategory,
        description: _descriptionController.text.isEmpty 
            ? null 
            : _descriptionController.text,
        paymentMethod: _selectedPaymentMethod,
      );
      
      Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(transaction);
      
      Navigator.pop(context);
    }
  }
}
