import 'package:cododoro/models/TimerModel.dart';
import 'package:cododoro/models/TimerStates.dart';
import 'package:test/test.dart';

void main() {
  test('timerModel initial state is noSession', () {
    final timerModel = TimerStateModel();

    expect(timerModel.state, TimerStates.noSession);
  });

  test('timerModel pause', () {
    final timerModel = TimerStateModel();
    timerModel.state = TimerStates.sessionResting;

    expect(timerModel.isPaused, false);

    timerModel.pauseResume();

    expect(timerModel.isPaused, true);

    timerModel.pauseResume();

    expect(timerModel.isPaused, false);
  });

  test('timerModel isRunning', () {
    final timerModel = TimerStateModel();

    expect(timerModel.isRunning(), false);

    timerModel.state = TimerStates.sessionWorking;

    expect(timerModel.isRunning(), true);

    timerModel.pauseResume();

    expect(timerModel.isRunning(), false);
  });
  
}
