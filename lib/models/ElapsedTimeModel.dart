import 'package:flutter/material.dart';

class ElapsedTimeModel with ChangeNotifier {
    int _elapsedTime = 0;

  int get elapsedTime {
    return _elapsedTime;
  }

  set elapsedTime(newTime) {
    _elapsedTime = newTime;
  }

  void onTick() {
    _elapsedTime += 1;
    notifyListeners();
  }
}