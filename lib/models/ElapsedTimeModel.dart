import 'package:flutter/material.dart';

class ElapsedTimeModel with ChangeNotifier {
  DateTime? _lastTickDateTime = null;

  Duration _elapsedTime = Duration(seconds: 0);

  int get elapsedTime {
    return _elapsedTime.inSeconds;
  }

  int get elapsedTimeMs {
    return _elapsedTime.inMilliseconds;
  }

  set elapsedTime(newTime) {
    _elapsedTime = Duration(seconds: newTime);
    _lastTickDateTime = null;
  }

  void onTick({required bool addTime}) {
    int additionalTime = _lastTickDateTime == null
        ? 100
        : (DateTime.now().subtract(Duration(
                milliseconds: _lastTickDateTime!.millisecondsSinceEpoch)))
            .millisecondsSinceEpoch;

    _lastTickDateTime = DateTime.now();
    if (addTime) {
      _elapsedTime += Duration(milliseconds: additionalTime);
    }
    notifyListeners();
  }
}
