import 'dart:async';

import 'package:cododoro/models/ElapsedTimeModel.dart';
import 'package:cododoro/models/TimerModel.dart';
import 'package:cododoro/models/TimerStates.dart';
import 'package:cododoro/notifiers/BaseNotifier.dart';
import 'package:cododoro/notifiers/LocalNotificationsNotifier.dart';
import 'package:cododoro/notifiers/SoundNotifier.dart';
import 'package:cododoro/storage/HistoryRepository.dart';
import 'package:cododoro/storage/NotificationsSchedule.dart';
import 'package:cododoro/storage/Settings.dart';

List<BaseNotifier> notifiers = [SoundNotifier(), LocalNotificationsNotifier()];

Future<void> _notifyAll(String message) async {
  notifiers.forEach((element) async {
    await element.notify(message);
  });
}

Timer? notificationsTimer;
int currentNotificationsDelayProgressionStep = 0;

void scheduleNotifications({int step = 0, String message = ""}) async {
  final duration = await NotificationSchedule().timeAtStep(step);
  print("Next notification in $duration minutes");
  notificationsTimer = Timer(Duration(minutes: duration), () async {
    currentNotificationsDelayProgressionStep = step + 1;
    await _notifyAll(message);
    scheduleNotifications(step: step + 1, message: message);
  });
}

void tick(ElapsedTimeModel elapsedTimeModel, TimerModel timerModel) async {
  if (timerModel.isRunning()) {
    Settings settings = new Settings();

    elapsedTimeModel.onTick();

    if (timerModel.state == TimerStates.sessionWorking &&
        elapsedTimeModel.elapsedTime > await settings.workDuration) {
      timerModel.state = TimerStates.sessionWorkingOvertime;
      await _notifyAll("Time to rest!");
      scheduleNotifications();
    } else if (timerModel.state == TimerStates.sessionResting &&
        elapsedTimeModel.elapsedTime > await settings.restDuration) {
      timerModel.state = TimerStates.sessionRestingOvertime;
      await _notifyAll("Time to work!");
      scheduleNotifications();
    }
  }
}

void startSession(ElapsedTimeModel elapsedTimeModel, TimerModel timerModel) {
  timerModel.state = TimerStates.sessionWorking;
  elapsedTimeModel.elapsedTime = 0;
  notificationsTimer?.cancel();
}

void pauseResume(TimerModel timerModel) {
  if (timerModel.isPaused && timerModel.isOvertime) {
    scheduleNotifications(step: currentNotificationsDelayProgressionStep + 1);
  } else {
    notificationsTimer?.cancel();
  }

  timerModel.pauseResume();
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

void timeScreenDispose() {
  notifiers.forEach((element) {
    element.dispose();
  });
}
