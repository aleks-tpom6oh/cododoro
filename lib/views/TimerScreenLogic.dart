import 'dart:async';

import 'package:programadoro/models/ElapsedTimeModel.dart';
import 'package:programadoro/models/TimerModel.dart';
import 'package:programadoro/models/TimerStates.dart';
import 'package:programadoro/notifiers/BaseNotifier.dart';
import 'package:programadoro/notifiers/SoundNotifier.dart';
import 'package:programadoro/storage/HistoryRepository.dart';
import 'package:programadoro/storage/NotificationsSchedule.dart';
import 'package:programadoro/storage/Settings.dart';

List<BaseNotifier> notifiers = [SoundNotifier()];

Future<void> _notifyAll() async {
  notifiers.forEach((element) async {
    await element.notify();
  });
}

Timer? notificationsTimer;

void scheduleNotifications({int step = 0}) async {
  final duration = await NotificationSchedule().timeAtStep(step);
  print("Next notification in $duration minutes");
  notificationsTimer = Timer(Duration(minutes: duration), () async {
    await _notifyAll();
    scheduleNotifications(step: step + 1);
  });
}

void tick(ElapsedTimeModel elapsedTimeModel, TimerModel timerModel) async {
  if (timerModel.isRunning()) {
    Settings settings = new Settings();

    elapsedTimeModel.onTick();

    if (timerModel.state == TimerStates.sessionWorking &&
        elapsedTimeModel.elapsedTime > await settings.workDuration) {
      timerModel.state = TimerStates.sessionWorkingOvertime;
      await _notifyAll();
      scheduleNotifications();
    } else if (timerModel.state == TimerStates.sessionResting &&
        elapsedTimeModel.elapsedTime > await settings.restDuration) {
      timerModel.state = TimerStates.sessionRestingOvertime;
      await _notifyAll();
      scheduleNotifications();
    }
  }
}

void startSession(ElapsedTimeModel elapsedTimeModel, TimerModel timerModel) {
  timerModel.state = TimerStates.sessionWorking;
  elapsedTimeModel.elapsedTime = 0;
  notificationsTimer?.cancel();
}

void stopSession(ElapsedTimeModel elapsedTimeModel, TimerModel timerModel) {
  saveSession(
      DateTime.now(),
      timerModel.isWorking ? IntervalType.work : IntervalType.rest,
      Duration(seconds: elapsedTimeModel.elapsedTime));

  timerModel.state = TimerStates.noSession;
  elapsedTimeModel.elapsedTime = 0;
  notificationsTimer?.cancel();
}

void nextStage(ElapsedTimeModel elapsedTimeModel, TimerModel timerModel) {
  notificationsTimer?.cancel();
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
    next:
    case TimerStates.noSession:
      {
        timerModel.state = TimerStates.sessionWorking;
        elapsedTimeModel.elapsedTime = 0;
      }
      break;
  }
}
