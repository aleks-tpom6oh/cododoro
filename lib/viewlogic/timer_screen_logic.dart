import 'dart:async';

import 'package:cododoro/data_layer/cubit/elapsed_time_cubit.dart';
import 'package:cododoro/data_layer/models/TimerStateModel.dart';
import 'package:cododoro/data_layer/models/TimerStates.dart';
import 'package:cododoro/notifications/BaseNotifier.dart';
import 'package:cododoro/notifications/LocalNotificationsNotifier.dart';
import 'package:cododoro/notifications/SoundNotifier.dart';
import 'package:cododoro/onboarding/OnboardingConfig.dart';
import 'package:cododoro/data_layer/storage/HistoryRepository.dart';
import 'package:cododoro/data_layer/storage/NotificationsSchedule.dart';
import 'package:cododoro/data_layer/storage/Settings.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';
import 'StandTimeRemaining.dart';
import 'isDayChangeOnTick.dart';

BaseNotifier soundNotifier = SoundNotifier();

List<BaseNotifier> notifiers = [soundNotifier, LocalNotificationsNotifier()];

Future<void> _notifyAll(String message,
    {String soundPath = 'assets/audio/alarm.mp3'}) async {
  notifiers.forEach((element) async {
    await element.notify(message, soundPath: soundPath);
  });
}

Timer? notificationsTimer;
int currentNotificationsDelayProgressionStep = 0;
bool skipNextAskStillStanding = false;

void scheduleOvertimeNotifications(
    {int step = 0,
    required String message,
    String soundPath = 'assets/audio/alarm.mp3'}) async {
  final duration = await NotificationSchedule().timeAtStep(step);
  notificationsTimer = Timer(Duration(minutes: duration), () async {
    currentNotificationsDelayProgressionStep = step + 1;
    await _notifyAll(message, soundPath: soundPath);
    scheduleOvertimeNotifications(step: step + 1, message: message);
  });
}

String getNotificationMessage(TimerStateModel timerModel) {
  if (timerModel.state == TimerStates.sessionRestingOvertime) {
    return "Time to work!";
  } else if (timerModel.state == TimerStates.sessionWorkingOvertime) {
    return "Time to rest!";
  } else {
    return "The time has come!";
  }
}

String getNotificationSound(TimerStateModel timerModel) {
  return 'assets/audio/alarm.mp3';
}

void tick(ElapsedTimeCubit elapsedTimeCubit, TimerStateModel timerModel,
    HistoryRepository history, Settings settings, SharedPreferences prefs,
    {required bool isStanding,
    required Function() onReachedStandingGoal,
    required IsDayChangeOnTick isDayChangeOnTick}) async {
  elapsedTimeCubit.onTick(addTime: timerModel.isRunning());

  syncSession(elapsedTimeCubit, history, timerModel);

  if (timerModel.isRunning()) {
    await notifyIfStandingGoalReached(
        timerModel, settings, history, isStanding, onReachedStandingGoal);

    await handleOvertime(timerModel, elapsedTimeCubit, settings);
  }

  if (isDayChangeOnTick.isDayChangeOnTick(DateTime.now(), prefs)) {
    stopSession(elapsedTimeCubit, timerModel, history);
  }
}

void onOnboardingConfigLoaded(
    OnboardingConfig config,
    ElapsedTimeCubit elapsedTimeCubit,
    TimerStateModel timerModel,
    HistoryRepository history,
    bool isStanding) {
  if (config.stepShown >= 1) {
    nextStage(elapsedTimeCubit, timerModel, history, isStanding);
  }
}

Future<void> handleOvertime(TimerStateModel timerModel,
    ElapsedTimeCubit elapsedTimeCubit, Settings settings) async {
  if (timerModel.state == TimerStates.sessionWorking &&
      elapsedTimeCubit.state.elapsedTime.inSeconds > await settings.workDuration) {
    timerModel.state = TimerStates.sessionWorkingOvertime;
    await _notifyAll(getNotificationMessage(timerModel),
        soundPath: getNotificationSound(timerModel));
    scheduleOvertimeNotifications(
        message: getNotificationMessage(timerModel),
        soundPath: getNotificationSound(timerModel));
  } else if (timerModel.state == TimerStates.sessionResting &&
      elapsedTimeCubit.state.elapsedTime.inSeconds > await settings.restDuration) {
    timerModel.state = TimerStates.sessionRestingOvertime;
    await _notifyAll(getNotificationMessage(timerModel),
        soundPath: getNotificationSound(timerModel));
    scheduleOvertimeNotifications(
        message: getNotificationMessage(timerModel),
        soundPath: getNotificationSound(timerModel));
  } else if (timerModel.state == TimerStates.sessionWorkingOvertime &&
      elapsedTimeCubit.state.elapsedTime.inSeconds < await settings.workDuration) {
    timerModel.state = TimerStates.sessionWorking;
    notificationsTimer?.cancel();
  } else if (timerModel.state == TimerStates.sessionRestingOvertime &&
      elapsedTimeCubit.state.elapsedTime.inSeconds < await settings.restDuration) {
    timerModel.state = TimerStates.sessionResting;
    notificationsTimer?.cancel();
  }
}

late ConfettiController confetti;
Duration? _previousStandTimeTillGoal = null;
Future<void> notifyIfStandingGoalReached(
    TimerStateModel timerModel,
    Settings settings,
    HistoryRepository history,
    bool isStanding,
    Function() onReachedStandingGoal) async {
  final hasStandingDesk = settings.standingDesk;

  if (hasStandingDesk) {
    final newStandTimeTillGoal = calculateRemainingStandTime(history, settings);
    if (timerModel.isWorking &&
        isStanding &&
        (_previousStandTimeTillGoal == null ||
            _previousStandTimeTillGoal! >= Duration(seconds: 0)) &&
        newStandTimeTillGoal < Duration(seconds: 0)) {
      confetti.play();
      await _notifyAll("🎉 Congrats, you've reached your daily standing goal",
          soundPath: 'assets/audio/endingsound.mp3');
      onReachedStandingGoal();
    }

    _previousStandTimeTillGoal = newStandTimeTillGoal;
  }
}

void startWorkSession(ElapsedTimeCubit elapsedTimeCubit,
    TimerStateModel timerModel, HistoryRepository history) {
  if (timerModel.state == TimerStates.noSession) {
    timerModel.state = TimerStates.sessionWorking;
    timerModel.forceResume();
    elapsedTimeCubit.reset();
    notificationsTimer?.cancel();

    history.startSession(IntervalType.work);

    soundNotifier.notify("",
        soundPath: "assets/audio/t-bell.mp3",
        delay: Duration(milliseconds: 200));
  }
}

void startStandingSessionByUser(
    HistoryRepository history, TimerStateModel timerModel) {
  skipNextAskStillStanding = timerModel.state == TimerStates.sessionResting ||
      timerModel.state == TimerStates.sessionRestingOvertime;
  history.startSession(IntervalType.stand);
}

bool shouldAskStillStanding(bool isStanding, TimerStateModel timerModel) {
  if (skipNextAskStillStanding) {
    skipNextAskStillStanding = false;

    return false;
  }

  return isStanding &&
      (timerModel.state == TimerStates.sessionResting ||
          timerModel.state == TimerStates.sessionRestingOvertime);
}

void stopStandingSession(HistoryRepository history) {
  history.updateCurrentStandingSession();
  history.stopStanding();
}

void pauseResume(TimerStateModel timerModel) {
  if (timerModel.isPaused && timerModel.isOvertime) {
    scheduleOvertimeNotifications(
        step: currentNotificationsDelayProgressionStep + 1,
        message: getNotificationMessage(timerModel));
  } else {
    notificationsTimer?.cancel();
  }

  timerModel.pauseResume();
}

void syncSession(ElapsedTimeCubit elapsedTimeCubit, HistoryRepository history,
    TimerStateModel timerModel) {
  if (timerModel.isRunning()) {
    history.updateCurrentPomodoroSession(
        DateTime.now(), Duration(seconds: elapsedTimeCubit.state.elapsedTime.inSeconds));
  }
  history.updateCurrentStandingSession(addTime: timerModel.isWorking);
}

void stopSession(ElapsedTimeCubit elapsedTimeCubit, TimerStateModel timerModel,
    HistoryRepository history) {
  if (timerModel.state != TimerStates.noSession) {
    history.updateCurrentPomodoroSession(
        DateTime.now(), Duration(seconds: elapsedTimeCubit.state.elapsedTime.inSeconds));

    timerModel.state = TimerStates.noSession;
    elapsedTimeCubit.reset();
  }
  notificationsTimer?.cancel();
}

String currentSessionName(TimerStateModel timerModel) {
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

String currentStateGifPath(TimerStateModel timerModel) {
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

void maybeSuggestStanding(bool isStanding, TimerStateModel timerModel,
    HistoryRepository history, Settings settings, Function(bool) result) async {
  final todayIntervals = await history.getTodayIntervals();

  final standingDesk = await settings.standingDesk;
  final standingReminderHour = await settings.standingReminderHour;

  final standingDuration =
      calculateTimeForIntervalType(todayIntervals, IntervalType.stand);

  final targetStandingMinutes = await settings.targetStandingMinutes;

  final currentDayHour = DateTime.now().hour;
  if (!isStanding &&
      !timerModel.isWorking &&
      standingDuration.compareTo(Duration(minutes: targetStandingMinutes)) <
          0 &&
      standingDesk &&
      currentDayHour > standingReminderHour) {
    result.call(true);

    return;
  } else {
    result.call(false);

    return;
  }
}

bool shouldShowWorkEndedDialogOnNextStageClick(TimerStateModel timerModel) {
  return timerModel.state == TimerStates.sessionWorking ||
      timerModel.state == TimerStates.sessionWorkingOvertime;
}

void nextStage(ElapsedTimeCubit elapsedTimeCubit, TimerStateModel timerModel,
    HistoryRepository history, bool isStanding) async {
  notificationsTimer?.cancel();
  switch (timerModel.state) {
    case TimerStates.sessionWorking:
    case TimerStates.sessionWorkingOvertime:
      {
        history.updateCurrentPomodoroSession(
            DateTime.now(), Duration(seconds: elapsedTimeCubit.state.elapsedTime.inSeconds));
        timerModel.state = TimerStates.sessionResting;
        elapsedTimeCubit.reset();
        stopStandingSession(history);
        history.startSession(IntervalType.rest);
      }
      break;
    case TimerStates.sessionResting:
    case TimerStates.sessionRestingOvertime:
      {
        history.updateCurrentPomodoroSession(
            DateTime.now(), Duration(seconds: elapsedTimeCubit.state.elapsedTime.inSeconds));
      }
      continue next;
    next:
    case TimerStates.noSession:
      {
        timerModel.state = TimerStates.sessionWorking;
        elapsedTimeCubit.reset();
        if (isStanding) {
          history.startSession(IntervalType.stand);
        }

        history.startSession(IntervalType.work);

        soundNotifier.notify("",
            soundPath: "assets/audio/t-bell.mp3",
            delay: Duration(milliseconds: 200));
      }
      break;
  }
  timerModel.forceResume();
}

void timerScreenInitState() {
  confetti = ConfettiController(duration: const Duration(seconds: 10));

  soundNotifier = SoundNotifier();

  notifiers = [soundNotifier, LocalNotificationsNotifier()];
}

void timeScreenDispose() {
  confetti.dispose();
  notifiers.forEach((element) {
    element.dispose();
  });
}

void stopAllSounds() {
  notifiers.remove(soundNotifier);
  soundNotifier.dispose();
  soundNotifier = SoundNotifier();
  notifiers.add(soundNotifier);
}
