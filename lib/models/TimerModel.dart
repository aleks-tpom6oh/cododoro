import 'package:flutter/foundation.dart';
import 'package:cododoro/models/TimerStates.dart';

class TimerStateModel with ChangeNotifier {
  TimerStates _state = TimerStates.sessionWorking;

  TimerStates get state {
    return _state;
  }

  set state(newState) {
    _state = newState;
    notifyListeners();
  }

  bool _isPaused = false;

  bool get isPaused {
    return _isPaused && state != TimerStates.noSession;
  }

  bool get isWorking {
    return !_isPaused && (_state == TimerStates.sessionWorking ||
        _state == TimerStates.sessionWorkingOvertime);
  }

  bool get isOvertime {
    return _state == TimerStates.sessionRestingOvertime ||
        _state == TimerStates.sessionWorkingOvertime;
  }

  bool get isResting {
    return !_isPaused && (_state == TimerStates.sessionResting ||
        _state == TimerStates.sessionRestingOvertime);
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
