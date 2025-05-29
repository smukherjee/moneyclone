import 'package:flutter/material.dart';
import 'package:money_clone/data/models.dart';
import 'package:money_clone/logic/providers.dart';
import 'package:money_clone/ui/widgets.dart';
import 'package:money_clone/services/navigation_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Clone'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          // Store providers before async gap to avoid using BuildContext across async gap
          final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
          final accountProvider = Provider.of<AccountProvider>(context, listen: false);
          
          return Future.wait([
            transactionProvider.fetchTransactions(),
            accountProvider.fetchAccounts(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance card
              Consumer2<TransactionProvider, AccountProvider>(
                builder: (context, transactionProvider, accountProvider, _) {
                  final totalIncome = transactionProvider.getTotalIncome();
                  final totalExpense = transactionProvider.getTotalExpense();
                  final balance = transactionProvider.getBalance();

                  return BalanceCard(
                    balance: balance,
                    income: totalIncome,
                    expenses: totalExpense,
                    onTap: () {
                      // Navigate to Accounts tab
                      context.read<NavigationService>().navigateToTab(3);
                    },
                  );
                },
              ),

              // Expense chart
              _buildExpenseChart(context),

              // Recent transactions
              SectionHeader(
                title: 'Recent Transactions',
                onSeeAllPressed: () {
                  // Navigate to Transactions tab
                  context.read<NavigationService>().navigateToTab(1);
                },
              ),
              _buildRecentTransactions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseChart(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final categorySpending = provider.getCategorySpending(TransactionType.expense);
        
        if (categorySpending.isEmpty) {
          return const SizedBox(height: 200);
        }
        
        // Build a list representation of the data instead of using SyncFusion charts
        return Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expense by Category',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildCategoryList(categorySpending),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryList(Map<String, double> categorySpending) {
    final total = categorySpending.values.fold(0.0, (sum, amount) => sum + amount);
    final sortedEntries = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return ListView.builder(
      shrinkWrap: true,
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        final percentage = (entry.value / total * 100).toStringAsFixed(1);
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.primaries[index % Colors.primaries.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text(
                  entry.key,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                flex: 3,
                child: LinearProgressIndicator(
                  value: entry.value / total,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.primaries[index % Colors.primaries.length],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  '$percentage%',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final recentTransactions = provider.getRecentTransactions();
        
        if (recentTransactions.isEmpty) {
          return EmptyStateWidget(
            message: 'No transactions yet. Tap + to add one.',
            icon: Icons.receipt_long_outlined,
            onActionPressed: () {
              // Navigate to transactions tab to add a new transaction
              context.read<NavigationService>().navigateToTab(1);
            },
            actionLabel: 'Add Transaction',
          );
        }
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentTransactions.length,
          itemBuilder: (context, index) {
            return TransactionListItem(
              transaction: recentTransactions[index],
              onTap: () {
                // Navigate to transactions tab to show details
                context.read<NavigationService>().navigateToTab(1);
              },
            );
          },
        );
      },
    );
  }
}

class ChartData {
  final String category;
  final double amount;

  ChartData(this.category, this.amount);
}
