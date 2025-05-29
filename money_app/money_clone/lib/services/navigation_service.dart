import 'package:flutter/material.dart';
import 'package:money_clone/ui/accounts_screen.dart';
import 'package:money_clone/ui/transaction_screen.dart';

class NavigationService extends ChangeNotifier {
  int _currentIndex = 0;
  
  int get currentIndex => _currentIndex;
  
  String get floatingActionButtonLabel {
    switch (_currentIndex) {
      case 1: // Transactions tab
        return 'Add Transaction';
      case 3: // Accounts tab
        return 'Add Account';
      default:
        return ''; // No FAB for other tabs
    }
  }
  
  void navigateToTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }
    void onFloatingActionButtonPressed(BuildContext context) {    switch (_currentIndex) {
      case 1:
        // Show add transaction dialog
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const AddTransactionSheet(),
        );
        break;
      case 3:
        // Show add account dialog
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const AddAccountSheet(),
        );
        break;
      default:
        // Default to transactions
        navigateToTab(1);
        // Add delay to allow screen transition before showing dialog
        Future.delayed(const Duration(milliseconds: 300), () {
          // Show add transaction dialog
        });
    }
  }
}
