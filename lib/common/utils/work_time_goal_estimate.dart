import 'dart:math';

import 'package:cododoro/common/data_layer/persistent/history_repository.dart';
import 'package:cododoro/common/data_layer/persistent/settings.dart';

DateTime estimateWorkGoalTime(HistoryRepository historyRepository,
    Settings settings, Duration workTimeTillGoal) {
  // if currently working:
  // current (time left from current interval)
  // count how many (full work intervals left) = (left work duration - (time left from current interval)) / (work interval duration)
  // add (rest duration) * (work intervals left)
  // add (time left from current interval)
  // else
  // count how many (full work intervals left) = (left work duration) / (work interval duration)
  // add (rest duration) * (work intervals left - 1)
  // substract (rest interval - current rest interval)

  StoredInterval? latestInterval =
      historyRepository.getLatestPomodoroInterval();

  Duration estimatedTotalTime;
  if (latestInterval?.type == IntervalType.work) {
    final Duration timeLeftThisInterval = Duration(
        seconds:
            max(0, settings.workDuration - latestInterval!.duration.inSeconds));

    final Duration workTimeLeftAfterCurrentInterval =
        (workTimeTillGoal - timeLeftThisInterval);

    final int fullWorkIntervalsLeft =
        (workTimeLeftAfterCurrentInterval.inMilliseconds /
                Duration(seconds: settings.workDuration).inMilliseconds)
            .floor();

    final Duration extraWorkTime = workTimeTillGoal -
        timeLeftThisInterval -
        Duration(seconds: fullWorkIntervalsLeft * settings.workDuration);

    final int numberOfRestIntervalsLeft = extraWorkTime.inSeconds > 0
        ? fullWorkIntervalsLeft + 1
        : fullWorkIntervalsLeft;

    final Duration estimatedRestTime =
        Duration(seconds: numberOfRestIntervalsLeft * settings.restDuration);

    estimatedTotalTime = timeLeftThisInterval +
        extraWorkTime +
        Duration(seconds: fullWorkIntervalsLeft * settings.workDuration) +
        estimatedRestTime;
  } else {
    final int fullWorkIntervalsLeft = (workTimeTillGoal.inMilliseconds /
            Duration(seconds: settings.workDuration).inMilliseconds)
        .floor();

    final Duration extraWorkTime = workTimeTillGoal -
        Duration(seconds: fullWorkIntervalsLeft * settings.workDuration);

    final int numberOfRestIntervalsLeft = extraWorkTime.inSeconds > 0
        ? fullWorkIntervalsLeft - 1
        : fullWorkIntervalsLeft - 2;

    final Duration estimatedRestTime =
        Duration(seconds: numberOfRestIntervalsLeft * settings.restDuration);

    final Duration restTimeLeftThisInterval = Duration(
        seconds: latestInterval != null
            ? max(0, settings.restDuration - latestInterval.duration.inSeconds)
            : 0);

    estimatedTotalTime = restTimeLeftThisInterval +
        extraWorkTime +
        Duration(seconds: fullWorkIntervalsLeft * settings.workDuration) +
        estimatedRestTime;
  }

  return DateTime.now().add(estimatedTotalTime);
}
