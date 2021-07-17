import 'package:flutter/foundation.dart';
import 'package:programadoro/models/TimerStates.dart';

class TimerModel with ChangeNotifier {
  TimerStates _state = TimerStates.noSession;

  TimerStates get state {
    return _state;
  }

  set state(newState) {
    _state = newState;
    notifyListeners();
  }

  bool _isPaused = false;

  bool get isPaused {
    return _isPaused;
  }

  bool isRunning() {
    return !isPaused && state != TimerStates.noSession;
  }

  void pauseResume() {
    _isPaused = !_isPaused;
    notifyListeners();
  }
}
