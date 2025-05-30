import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_clone/data/models.dart' as models;
import 'package:money_clone/logic/providers.dart';
import 'package:money_clone/ui/theme.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});
  static IconData getAccountTypeIcon(models.AccountType type) {
    switch (type) {
      case models.AccountType.checking:
        return Icons.account_balance;
      case models.AccountType.savings:
        return Icons.savings;
      case models.AccountType.cash:
        return Icons.money;
      case models.AccountType.creditCard:
        return Icons.credit_card;
      case models.AccountType.investment:
        return Icons.trending_up;
      case models.AccountType.other:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: Consumer<AccountProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final accounts = provider.accounts;

          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No accounts yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first account to start tracking your finances',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddAccountDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Account'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildTotalBalanceCard(context, provider),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return _buildAccountCard(context, account);
                  },
                ),
              ),
            ],
          );
        },
      ),
      // We don't need a FloatingActionButton here as it's already handled by MainScreen
      // through the NavigationService
    );
  }

  Widget _buildTotalBalanceCard(
    BuildContext context,
    AccountProvider provider,
  ) {
    final totalBalance = provider.getTotalBalance();
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withBlue(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(totalBalance),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total of ${provider.accounts.length} accounts',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, models.Account account) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    IconData accountIcon = AccountsScreen.getAccountTypeIcon(account.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to account detail screen
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  accountIcon,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (account.bankName != null)
                      Text(
                        account.bankName!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    if (account.accountNumber != null)
                      Text(
                        account.accountNumber!.length >= 4
                            ? 'xxxx ${account.accountNumber!.substring(account.accountNumber!.length - 4)}'
                            : 'xxxx ${account.accountNumber!}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              Text(
                currencyFormat.format(account.balance),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      account.balance >= 0
                          ? AppTheme.incomeColor
                          : AppTheme.expenseColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAccountSheet(),
    );
  }
}

class AddAccountSheet extends StatefulWidget {
  const AddAccountSheet({super.key});

  @override
  State<AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<AddAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  models.AccountType _selectedAccountType = models.AccountType.checking;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
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
                  'Add Account',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),

                // Account type selector
                Text(
                  'Account Type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: models.AccountType.values.length,
                    itemBuilder: (context, index) {
                      final type = models.AccountType.values[index];
                      final isSelected = type == _selectedAccountType;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedAccountType = type;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 80,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppTheme.primaryColor.withOpacity(0.1)
                                      : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppTheme.primaryColor
                                        : Colors.grey.shade300,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  AccountsScreen.getAccountTypeIcon(type),
                                  color:
                                      isSelected
                                          ? AppTheme.primaryColor
                                          : Colors.grey.shade700,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  type.name.replaceFirst(
                                    type.name[0],
                                    type.name[0].toUpperCase(),
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isSelected
                                            ? AppTheme.primaryColor
                                            : Colors.grey.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Account name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    hintText: 'e.g., Cash, Savings Account',
                    prefixIcon: Icon(Icons.account_balance_wallet),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an account name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Balance field
                TextFormField(
                  controller: _balanceController,
                  decoration: const InputDecoration(
                    labelText: 'Current Balance',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the current balance';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Bank name field (optional)
                TextFormField(
                  controller: _bankNameController,
                  decoration: const InputDecoration(
                    labelText: 'Bank Name (Optional)',
                    hintText: 'e.g., Chase, Bank of America',
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                ),
                const SizedBox(height: 16),

                // Account number field (optional)
                TextFormField(
                  controller: _accountNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Account Number (Optional)',
                    hintText: 'Last 4 digits will be displayed',
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // Save button
                ElevatedButton(
                  onPressed: _saveAccount,
                  child: const Text('Save Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      final account = models.Account(
        id: const Uuid().v4(),
        name: _nameController.text,
        balance: double.parse(_balanceController.text),
        type: _selectedAccountType,
        bankName:
            _bankNameController.text.isEmpty ? null : _bankNameController.text,
        accountNumber:
            _accountNumberController.text.isEmpty
                ? null
                : _accountNumberController.text,
      );

      Provider.of<AccountProvider>(context, listen: false).addAccount(account);

      Navigator.pop(context);
    }
  }
}
