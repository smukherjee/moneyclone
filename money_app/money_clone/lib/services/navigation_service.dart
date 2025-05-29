import 'package:flutter/foundation.dart';

class NavigationService extends ChangeNotifier {
  int _currentIndex = 0;
  
  int get currentIndex => _currentIndex;
  
  void navigateToTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
