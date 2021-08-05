import 'dart:math';

import 'package:programadoro/storage/BaseSharedPrefs.dart';

enum Strategy { Fibonacci, Linear }

const fibonaccis = [1, 2, 3, 5, 8, 13, 21, 34, 55];

class NotificationSchedule extends BaseSharedPrefs {
  Future<Strategy> get _strategy async {
    final strategyIndex = (await prefs).getInt("NOTIFICATIONS_STRATEGY") ?? 0;
    return Strategy.values[min(Strategy.values.length, strategyIndex)];
  }

  void setStrategy(Strategy newStrategy) async {
    (await prefs).setInt("NOTIFICATIONS_STRATEGY", newStrategy.index);
    notifyListeners();
  }

  Future<int> get _baseTime async {
    return (await prefs).getInt("NOTIFICATIONS_BASE_TIME") ?? 8;
  }

  void setBaseTime(int newBaseTime) async {
    (await prefs).setInt("NOTIFICATIONS_BASE_TIME", newBaseTime);
    notifyListeners();
  }

  Future<List<int>> computeTimes() async {
    switch (await _strategy) {
      case Strategy.Fibonacci:
        {
          final initialStep = fibonaccis.indexOf(await _baseTime) + 1;
          return fibonaccis.sublist(0, initialStep).reversed.toList();
        }
      case Strategy.Linear:
        {
          return List.generate(await _baseTime, (index) => index)
              .reversed
              .toList();
        }
    }
  }

  Future<int> timeAtStep(step) async {
    final durations = (await NotificationSchedule().computeTimes());

    if (step < durations.length) {
      return durations[step];
    } else {
      return 1;
    }
  }
}
