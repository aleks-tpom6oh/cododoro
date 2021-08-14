import 'package:flutter/foundation.dart';
import 'package:cododoro/models/TimerStates.dart';

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

  bool get isWorking {
    return _state == TimerStates.sessionWorking ||
        _state == TimerStates.sessionWorkingOvertime;
  }

  bool get isOvertime {
     return _state == TimerStates.sessionRestingOvertime ||
        _state == TimerStates.sessionWorkingOvertime;
  }

  bool get isResing {
    return _state == TimerStates.sessionResting ||
        _state == TimerStates.sessionRestingOvertime;
  }

  bool get isChilling {
    return _state == TimerStates.noSession;
  }

  bool isRunning() {
    return !isPaused && state != TimerStates.noSession;
  }

  void pauseResume() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  void forceResume() {
    _isPaused = false;
    notifyListeners();
  }
}
