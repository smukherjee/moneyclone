import 'package:flutter/material.dart';
import 'package:money_clone/ui/accounts_screen.dart';
import 'package:money_clone/ui/home_screen.dart';
import 'package:money_clone/ui/reports_screen.dart';
import 'package:money_clone/ui/transaction_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionScreen(),
    const ReportsScreen(),
    const AccountsScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            activeIcon: Icon(Icons.pie_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Accounts',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1 ? null : FloatingActionButton(
        onPressed: () {
          // Redirect to transaction screen with add transaction dialog
          setState(() {
            _currentIndex = 1;
          });
          // Add delay to allow screen transition before showing dialog
          Future.delayed(const Duration(milliseconds: 300), () {
            // Show add transaction dialog
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
