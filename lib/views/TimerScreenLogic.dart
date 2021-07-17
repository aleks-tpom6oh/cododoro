import 'package:programadoro/models/ElapsedTimeModel.dart';
import 'package:programadoro/models/TimerModel.dart';
import 'package:programadoro/models/TimerStates.dart';
import 'package:programadoro/storage/Settings.dart';

void tick(ElapsedTimeModel elapsedTimeModel, TimerModel timerModel) async {
  if (timerModel.isRunning()) {
    Settings settings = new Settings();

    elapsedTimeModel.onTick();

    if (timerModel.state == TimerStates.sessionWorking &&
        elapsedTimeModel.elapsedTime > await settings.workDuration) {
      timerModel.state = TimerStates.sessionWorkingOvertime;
    } else if (timerModel.state == TimerStates.sessionResting &&
        elapsedTimeModel.elapsedTime > await settings.restDuration) {
      timerModel.state = TimerStates.sessionRestingOvertime;
    }
  }
}

void nextStage(ElapsedTimeModel elapsedTimeModel, TimerModel timerModel) {
  switch (timerModel.state) {
    case TimerStates.sessionWorking:
    case TimerStates.sessionWorkingOvertime:
      {
        timerModel.state = TimerStates.sessionResting;
        elapsedTimeModel.elapsedTime = 0;
      }
      break;
    case TimerStates.noSession:
    case TimerStates.sessionResting:
    case TimerStates.sessionRestingOvertime:
      {
        timerModel.state = TimerStates.sessionWorking;
        elapsedTimeModel.elapsedTime = 0;
      }
      break;
    case TimerStates.noSession:
      {
        timerModel.state = timerModel.state == TimerStates.sessionWorking
            ? TimerStates.sessionResting
            : TimerStates.sessionWorking;
      }
  }
}
