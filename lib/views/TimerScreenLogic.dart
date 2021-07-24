import 'package:programadoro/models/ElapsedTimeModel.dart';
import 'package:programadoro/models/TimerModel.dart';
import 'package:programadoro/models/TimerStates.dart';
import 'package:programadoro/storage/HistoryRepository.dart';
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

void startSession(ElapsedTimeModel elapsedTimeModel, TimerModel timerModel) {
    timerModel.state = TimerStates.sessionWorking;
    elapsedTimeModel.elapsedTime = 0;
}

void stopSession(ElapsedTimeModel elapsedTimeModel, TimerModel timerModel) {
    timerModel.state = TimerStates.noSession;
    elapsedTimeModel.elapsedTime = 0;
}

void nextStage(ElapsedTimeModel elapsedTimeModel, TimerModel timerModel) {
  switch (timerModel.state) {
    case TimerStates.sessionWorking:
    case TimerStates.sessionWorkingOvertime:
      {
        saveSession(DateTime.now(), IntervalType.work,
            Duration(seconds: elapsedTimeModel.elapsedTime));
        timerModel.state = TimerStates.sessionResting;
        elapsedTimeModel.elapsedTime = 0;
      }
      break;
    case TimerStates.sessionResting:
    case TimerStates.sessionRestingOvertime:
    {
        saveSession(DateTime.now(), IntervalType.rest,
            Duration(seconds: elapsedTimeModel.elapsedTime));
    }
    continue next;
    next:case TimerStates.noSession:
      {
        timerModel.state = TimerStates.sessionWorking;
        elapsedTimeModel.elapsedTime = 0;
      }
      break;
  }
}
