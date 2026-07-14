import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  BuildContext context;

  bool _sidebarisOpen = true;
  bool get sidebarisOpen => _sidebarisOpen;
  double sidebarWidth = 250;

  HomeProvider(this.context);

  void toggleSidebar() {
    _sidebarisOpen = !_sidebarisOpen;
    notifyListeners();
  }
}
