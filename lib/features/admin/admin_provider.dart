import 'package:flutter/material.dart';

class AdminProvider extends ChangeNotifier {
  int currentToken = 104;

  void serveNext() {
    currentToken++;
    notifyListeners();
  }
}
