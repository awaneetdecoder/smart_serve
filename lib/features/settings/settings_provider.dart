import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool notifyNext = true;

  void toggleNotify(bool value) {
    notifyNext = value;
    notifyListeners();
  }
}
