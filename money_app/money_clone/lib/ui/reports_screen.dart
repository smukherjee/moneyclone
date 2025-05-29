import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_clone/data/models.dart';
import 'package:money_clone/logic/providers.dart';
import 'package:money_clone/ui/theme.dart';
import 'package:provider/provider.dart';
// import 'package:syncfusion_flutter_charts/charts.dart'; // Removed due to compatibility issues

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'Last 3 Months', 'This Year', 'Custom'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Categories'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildCategoriesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Time Period',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        value: _selectedPeriod,
        items: _periods.map((period) => DropdownMenuItem(
          value: period,
          child: Text(period),
        )).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedPeriod = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(provider),
              const SizedBox(height: 24),
              Text(
                'Income vs Expenses',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildPlaceholderChart(
                'Income vs Expenses Chart', 
                'Income: \$${provider.getTotalIncome().toStringAsFixed(2)}\nExpenses: \$${provider.getTotalExpense().toStringAsFixed(2)}'
              ),
              const SizedBox(height: 24),
              Text(
                'Transaction Trend',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildPlaceholderChart('Transaction Trend Chart', 'Historical transaction data will be displayed here'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expense by Category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildCategoryList(provider, TransactionType.expense),
              const SizedBox(height: 24),
              Text(
                'Income by Category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildCategoryList(provider, TransactionType.income),
              const SizedBox(height: 24),
              Text(
                'Top Spending Categories',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildTopCategoriesList(provider),
            ],
          ),
        );
      },
    );
  }
  Widget _buildSummaryCards(TransactionProvider provider) {
    final totalIncome = provider.getTotalIncome();
    final totalExpense = provider.getTotalExpense();
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.arrow_downward,
                    color: AppTheme.incomeColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Income',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(totalIncome),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.incomeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.arrow_upward,
                    color: AppTheme.expenseColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Expenses',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(totalExpense),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.expenseColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Placeholder for charts while SyncFusion charts are disabled
  Widget _buildPlaceholderChart(String title, String details) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Charts temporarily unavailable',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                details,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // List representation of category data
  Widget _buildCategoryList(TransactionProvider provider, TransactionType type) {
    final categorySpending = provider.getCategorySpending(type);
    
    if (categorySpending.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text('No ${type == TransactionType.income ? 'income' : 'expense'} data available for the selected period'),
        ),
      );
    }
    
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final total = categorySpending.values.fold(0.0, (sum, amount) => sum + amount);
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.pie_chart),
                const SizedBox(width: 8),
                Text(
                  '${type == TransactionType.income ? 'Income' : 'Expense'} Distribution',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categorySpending.length,
            itemBuilder: (context, index) {
              final entry = categorySpending.entries.elementAt(index);
              final percentage = (entry.value / total * 100).toStringAsFixed(1);
              
              return ListTile(
                title: Text(entry.key),
                subtitle: LinearProgressIndicator(
                  value: entry.value / total,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    type == TransactionType.income ? AppTheme.incomeColor : AppTheme.expenseColor,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(currencyFormat.format(entry.value)),
                    Text('$percentage%', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // List of top spending categories
  Widget _buildTopCategoriesList(TransactionProvider provider) {
    final categorySpending = provider.getCategorySpending(TransactionType.expense);
    
    if (categorySpending.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No expense data available for the selected period'),
        ),
      );
    }
    
    // Sort by amount (descending) and take top 5
    final sortedEntries = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topCategories = sortedEntries.take(5).toList();
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.trending_up),
                const SizedBox(width: 8),
                const Text(
                  'Top Spending Categories',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          for (var i = 0; i < topCategories.length; i++)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.expenseColor.withOpacity(0.8),
                child: Text('${i + 1}', style: const TextStyle(color: Colors.white)),
              ),
              title: Text(topCategories[i].key),
              trailing: Text(
                currencyFormat.format(topCategories[i].value),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

// These classes are kept for future use when charts are re-enabled
class ChartData {
  final String category;
  final double amount;
  final Color color;

  ChartData(this.category, this.amount, this.color);
}

class TimeSeriesData {
  final DateTime date;
  final double amount;

  TimeSeriesData(this.date, this.amount);
}
