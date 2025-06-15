import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_clone/data/models.dart';
import 'package:money_clone/logic/providers.dart';
import 'package:money_clone/ui/theme.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

// Chart data class for reports
class ChartData {
  final String category;
  final double amount;
  final DateTime? date;

  ChartData(this.category, this.amount, {this.date});
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';
  final List<String> _periods = [
    'This Week',
    'This Month',
    'Last 3 Months',
    'This Year',
    'Custom',
  ];

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
          tabs: const [Tab(text: 'Overview'), Tab(text: 'Categories')],
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, _) {
          final transactions = transactionProvider.transactions;
          final categorySpending = transactionProvider.getCategorySpending(
            TransactionType.expense,
          );

          return Column(
            children: [
              _buildPeriodSelector(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildOverviewTab(), _buildCategoriesTab()],
                ),
              ),
            ],
          );
        },
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
        items:
            _periods
                .map(
                  (period) =>
                      DropdownMenuItem(value: period, child: Text(period)),
                )
                .toList(),
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
              _buildIncomeVsExpenseChart(provider),
              const SizedBox(height: 24),
              Text(
                'Transaction Trend',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildTransactionTrendChart(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryPieChart(
    TransactionProvider provider,
    TransactionType type,
  ) {
    final categorySpending = provider.getCategorySpending(type);

    if (categorySpending.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('No data available')),
      );
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];

    final sections =
        categorySpending.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final categoryEntry = entry.value;
          final percentage =
              (categoryEntry.value /
                  categorySpending.values.reduce((a, b) => a + b)) *
              100;

          return PieChartSectionData(
            value: categoryEntry.value,
            title: '${categoryEntry.key}\n${percentage.toStringAsFixed(1)}%',
            color: colors[index % colors.length],
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
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
              _buildCategoryPieChart(provider, TransactionType.expense),
              const SizedBox(height: 24),
              Text(
                'Income by Category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildCategoryPieChart(provider, TransactionType.income),
              const SizedBox(height: 24),
              Text(
                'Top Categories',
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
                  const Icon(Icons.arrow_downward, color: AppTheme.incomeColor),
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
                  const Icon(Icons.arrow_upward, color: AppTheme.expenseColor),
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
  Widget _buildCategoryList(
    TransactionProvider provider,
    TransactionType type,
  ) {
    final categorySpending = provider.getCategorySpending(type);

    if (categorySpending.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No ${type == TransactionType.income ? 'income' : 'expense'} data available for the selected period',
          ),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final total = categorySpending.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );

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
                    type == TransactionType.income
                        ? AppTheme.incomeColor
                        : AppTheme.expenseColor,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(currencyFormat.format(entry.value)),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
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
    final categorySpending = provider.getCategorySpending(
      TransactionType.expense,
    );

    if (categorySpending.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No expense data available for the selected period'),
        ),
      );
    }

    // Sort by amount (descending) and take top 5
    final sortedEntries =
        categorySpending.entries.toList()
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
                backgroundColor: AppTheme.expenseColor.withAlpha(
                  (0.8 * 255).round(),
                ),
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
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

  Widget _buildIncomeVsExpenseChart(TransactionProvider provider) {
    final incomeAmount = provider.getTotalIncome();
    final expenseAmount = provider.getTotalExpense();

    if (incomeAmount == 0 && expenseAmount == 0) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('No data available')),
      );
    }

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: incomeAmount,
              title: 'Income\n\$${incomeAmount.toStringAsFixed(0)}',
              color: AppTheme.incomeColor,
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: expenseAmount,
              title: 'Expenses\n\$${expenseAmount.toStringAsFixed(0)}',
              color: AppTheme.expenseColor,
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          centerSpaceRadius: 50,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildTransactionTrendChart(TransactionProvider provider) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 2, 1); // Last 3 months
    final transactions = provider.transactions;

    // Group transactions by date and type
    final Map<DateTime, double> dailyIncome = {};
    final Map<DateTime, double> dailyExpenses = {};

    for (var transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      if (date.isAfter(startDate)) {
        if (transaction.type == TransactionType.income) {
          dailyIncome[date] = (dailyIncome[date] ?? 0) + transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          dailyExpenses[date] = (dailyExpenses[date] ?? 0) + transaction.amount;
        }
        // Note: Transfers are ignored in this chart as they're internal movements
      }
    }

    // Get all unique dates and sort them
    final allDates =
        <DateTime>{...dailyIncome.keys, ...dailyExpenses.keys}.toList()..sort();

    if (allDates.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('No data available')),
      );
    }

    // Create bar groups for the chart
    final barGroups =
        allDates.asMap().entries.map((entry) {
          final index = entry.key;
          final date = entry.value;
          final incomeAmount = dailyIncome[date] ?? 0;
          final expenseAmount = dailyExpenses[date] ?? 0;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: incomeAmount,
                color: AppTheme.incomeColor,
                width: 8,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: expenseAmount,
                color: AppTheme.expenseColor,
                width: 8,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList();

    // Find the maximum value for Y-axis scaling
    final maxIncome =
        dailyIncome.values.isNotEmpty
            ? dailyIncome.values.reduce((a, b) => a > b ? a : b)
            : 0;
    final maxExpense =
        dailyExpenses.values.isNotEmpty
            ? dailyExpenses.values.reduce((a, b) => a > b ? a : b)
            : 0;
    final maxY =
        (maxIncome > maxExpense ? maxIncome : maxExpense) *
        1.1; // Add 10% padding

    return Column(
      children: [
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 16, height: 16, color: AppTheme.incomeColor),
            const SizedBox(width: 8),
            const Text('Income'),
            const SizedBox(width: 24),
            Container(width: 16, height: 16, color: AppTheme.expenseColor),
            const SizedBox(width: 8),
            const Text('Expenses'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              groupsSpace: 12,
              barGroups: barGroups,
              gridData: FlGridData(show: true, horizontalInterval: maxY / 5),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '\$${value.toInt()}',
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < allDates.length) {
                        final date = allDates[value.toInt()];
                        return Text(
                          DateFormat('MM/dd').format(date),
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final date = allDates[group.x];
                    final isIncome = rodIndex == 0;
                    final type = isIncome ? 'Income' : 'Expenses';
                    return BarTooltipItem(
                      '$type\n${DateFormat('MMM dd').format(date)}\n\$${rod.toY.toStringAsFixed(2)}',
                      TextStyle(
                        color:
                            isIncome
                                ? AppTheme.incomeColor
                                : AppTheme.expenseColor,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
