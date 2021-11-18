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
import 'package:confetti/confetti.dart';

import '../utils.dart';
import 'StandTimeRemaining.dart';

List<BaseNotifier> notifiers = [SoundNotifier(), LocalNotificationsNotifier()];

Future<void> _notifyAll(String message,
    {String soundPath = 'assets/audio/alarm.mp3'}) async {
  notifiers.forEach((element) async {
    await element.notify(message, soundPath: soundPath);
  });
}

Timer? notificationsTimer;
int currentNotificationsDelayProgressionStep = 0;
bool skipNextSitDownSuggestion = false;

void scheduleOvertimeNotifications(
    {int step = 0, required String message}) async {
  final duration = await NotificationSchedule().timeAtStep(step);
  print("Next notification in $duration minutes");
  notificationsTimer = Timer(Duration(minutes: duration), () async {
    currentNotificationsDelayProgressionStep = step + 1;
    await _notifyAll(message);
    scheduleOvertimeNotifications(step: step + 1, message: message);
  });
}

String getNotificationMessage(TimerModel timerModel) {
  if (timerModel.state == TimerStates.sessionRestingOvertime) {
    return "Time to work!";
  } else if (timerModel.state == TimerStates.sessionWorkingOvertime) {
    return "Time to rest!";
  } else {
    return "The time has come!";
  }
}

void tick(ElapsedTimeModel elapsedTimeModel, TimerModel timerModel,
    HistoryRepository history, Settings settings,
    {required bool isStanding,
    required Function() onReachedStandingGoal}) async {
  elapsedTimeModel.onTick(addTime: timerModel.isRunning());

  await syncSession(elapsedTimeModel, history, timerModel);

  if (timerModel.isRunning()) {
    await notifyIfStandingGoalReached(
        timerModel, settings, history, isStanding, onReachedStandingGoal);

    if (timerModel.state == TimerStates.sessionWorking &&
        elapsedTimeModel.elapsedTime > await settings.workDuration) {
      timerModel.state = TimerStates.sessionWorkingOvertime;
      await _notifyAll(getNotificationMessage(timerModel));
      scheduleOvertimeNotifications(
          message: getNotificationMessage(timerModel));
    } else if (timerModel.state == TimerStates.sessionResting &&
        elapsedTimeModel.elapsedTime > await settings.restDuration) {
      timerModel.state = TimerStates.sessionRestingOvertime;
      await _notifyAll(getNotificationMessage(timerModel));
      scheduleOvertimeNotifications(
          message: getNotificationMessage(timerModel));
    } else if (timerModel.state == TimerStates.sessionWorkingOvertime &&
        elapsedTimeModel.elapsedTime < await settings.workDuration) {
      timerModel.state = TimerStates.sessionWorking;
      notificationsTimer?.cancel();
    } else if (timerModel.state == TimerStates.sessionRestingOvertime &&
        elapsedTimeModel.elapsedTime < await settings.restDuration) {
      timerModel.state = TimerStates.sessionResting;
      notificationsTimer?.cancel();
    }
  }
}

late ConfettiController confetti;
Duration? _previousStandTimeTillGoal = null;
Future<void> notifyIfStandingGoalReached(
    TimerModel timerModel,
    Settings settings,
    HistoryRepository history,
    bool isStanding,
    Function() onReachedStandingGoal) async {
  if (timerModel.isWorking &&
      isStanding &&
      (_previousStandTimeTillGoal == null ||
          _previousStandTimeTillGoal! >= Duration(seconds: 0))) {
    settings.standingDesk.then((hasStandingDesk) async {
      if (hasStandingDesk) {
        final newStandTimeTillGoal =
            await calculateRemainingStandTime(history, settings);

        if (newStandTimeTillGoal < Duration(seconds: 0)) {
          confetti.play();
          await _notifyAll(
              "🎉 Congrats, you've reached your daily standing goal",
              soundPath: 'assets/audio/endingsound.mp3');
          onReachedStandingGoal();
        }

        print("Stand time till goal $newStandTimeTillGoal");
        _previousStandTimeTillGoal = newStandTimeTillGoal;
      }
    });
  }
}

void startSession(ElapsedTimeModel elapsedTimeModel, TimerModel timerModel,
    HistoryRepository history) {
  if (timerModel.state == TimerStates.noSession) {
    timerModel.state = TimerStates.sessionWorking;
    timerModel.forceResume();
    elapsedTimeModel.elapsedTime = 0;
    notificationsTimer?.cancel();

    history.startSession(IntervalType.work);
  }
}

Future<void> startStanding(
    HistoryRepository history, TimerModel timerModel) async {
  skipNextSitDownSuggestion = timerModel.state == TimerStates.sessionResting ||
      timerModel.state == TimerStates.sessionRestingOvertime;
  await history.startSession(IntervalType.stand);
}

bool shouldAskStillStanding(bool isStanding, TimerModel timerModel) {
  if (skipNextSitDownSuggestion) {
    skipNextSitDownSuggestion = false;

    return false;
  }

  return isStanding && timerModel.state == TimerStates.sessionResting ||
      timerModel.state == TimerStates.sessionRestingOvertime;
}

Future<void> stopStanding(HistoryRepository history) async {
  await history.updateCurrentStandingSession();
  history.stopStanding();
}

void pauseResume(TimerModel timerModel) {
  if (timerModel.isPaused && timerModel.isOvertime) {
    scheduleOvertimeNotifications(
        step: currentNotificationsDelayProgressionStep + 1,
        message: getNotificationMessage(timerModel));
  } else {
    notificationsTimer?.cancel();
  }

  timerModel.pauseResume();
}

Future<void> syncSession(ElapsedTimeModel elapsedTimeModel,
    HistoryRepository history, TimerModel timerModel) async {
  if (timerModel.isRunning()) {
    await history.updateCurrentPomodoroSession(
        DateTime.now(), Duration(seconds: elapsedTimeModel.elapsedTime));
  }
  await history.updateCurrentStandingSession(addTime: timerModel.isWorking);
}

void stopSession(ElapsedTimeModel elapsedTimeModel, TimerModel timerModel,
    HistoryRepository history) async {
  if (timerModel.state != TimerStates.noSession) {
    await history.updateCurrentPomodoroSession(
        DateTime.now(), Duration(seconds: elapsedTimeModel.elapsedTime));

    timerModel.state = TimerStates.noSession;
    elapsedTimeModel.elapsedTime = 0;
  }
  notificationsTimer?.cancel();
}

String currentSessionName(TimerModel timerModel) {
  if (timerModel.isPaused) {
    return "Paused";
  }

  switch (timerModel.state) {
    case TimerStates.sessionWorking:
      return "Working";
    case TimerStates.sessionWorkingOvertime:
      return "Working Overtime";
    case TimerStates.sessionResting:
      return "Resting";
    case TimerStates.sessionRestingOvertime:
      return "Resting Overtime";
    case TimerStates.noSession:
      return "Chilling";
  }
}

String currentStateGifPath(TimerModel timerModel) {
  if (timerModel.isPaused) {
    return "assets/images/pause.gif";
  }

  switch (timerModel.state) {
    case TimerStates.noSession:
      return "assets/images/chilling.gif";
    case TimerStates.sessionResting:
    case TimerStates.sessionRestingOvertime:
      return "assets/images/resting.gif";
    case TimerStates.sessionWorking:
      return "assets/images/working.jpeg";
    case TimerStates.sessionWorkingOvertime:
      return "assets/images/working.gif";
  }
}

void maybeSuggestStanding(bool isStanding, TimerModel timerModel,
    HistoryRepository history, Settings settings, Function(bool) result) async {
  final todayIntervals = await history.getTodayIntervals();

  final standingDesk = await settings.standingDesk;

  final standingDuration =
      calculateTimeForIntervalType(todayIntervals, IntervalType.stand);

  final targetStandingMinutes = await settings.targetStandingMinutes;

  final currentDayHour = DateTime.now().hour;
  if (!isStanding &&
      !timerModel.isWorking &&
      standingDuration.compareTo(Duration(minutes: targetStandingMinutes)) <
          0 &&
      standingDesk &&
      currentDayHour > 14) {
    result.call(true);

    return;
  } else {
    result.call(false);

    return;
  }
}

bool shouldShowWorkEndedDialogOnNextStageClick(TimerModel timerModel) {
  return timerModel.state == TimerStates.sessionWorking ||
      timerModel.state == TimerStates.sessionWorkingOvertime;
}

Future<void> nextStage(ElapsedTimeModel elapsedTimeModel, TimerModel timerModel,
    HistoryRepository history) async {
  notificationsTimer?.cancel();
  switch (timerModel.state) {
    case TimerStates.sessionWorking:
    case TimerStates.sessionWorkingOvertime:
      {
        await history.updateCurrentPomodoroSession(
            DateTime.now(), Duration(seconds: elapsedTimeModel.elapsedTime));
        timerModel.state = TimerStates.sessionResting;
        elapsedTimeModel.elapsedTime = 0;
        await history.startSession(IntervalType.rest);
      }
      break;
    case TimerStates.sessionResting:
    case TimerStates.sessionRestingOvertime:
      {
        await history.updateCurrentPomodoroSession(
            DateTime.now(), Duration(seconds: elapsedTimeModel.elapsedTime));
      }
      continue next;
    next:
    case TimerStates.noSession:
      {
        timerModel.state = TimerStates.sessionWorking;
        elapsedTimeModel.elapsedTime = 0;
        await history.startSession(IntervalType.work);
      }
      break;
  }
  timerModel.forceResume();
}

void timerScreenInitState() {
  confetti = ConfettiController(duration: const Duration(seconds: 10));
}

void timeScreenDispose() {
  confetti.dispose();
  notifiers.forEach((element) {
    element.dispose();
  });
}
