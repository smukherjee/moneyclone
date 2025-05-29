import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_clone/ui/accounts_screen.dart';
import 'package:money_clone/ui/home_screen.dart';
import 'package:money_clone/ui/reports_screen.dart';
import 'package:money_clone/ui/transaction_screen.dart';
import 'package:money_clone/services/navigation_service.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationService(),
      child: Consumer<NavigationService>(
        builder: (context, navigationService, _) {
          return Scaffold(
            body: IndexedStack(
              index: navigationService.currentIndex,
              children: const [
                HomeScreen(),
                TransactionScreen(),
                ReportsScreen(),
                AccountsScreen(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: navigationService.currentIndex,
              onTap: navigationService.navigateToTab,
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
            floatingActionButton: navigationService.currentIndex == 1 ? null : FloatingActionButton(
              onPressed: () {
                // Navigate to transaction screen and show add dialog
                navigationService.navigateToTab(1);
                // Add delay to allow screen transition before showing dialog
                Future.delayed(const Duration(milliseconds: 300), () {
                  // Show add transaction dialog
                });
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
