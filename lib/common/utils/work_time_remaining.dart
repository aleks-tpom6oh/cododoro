import 'package:cododoro/common/data_layer/persistent/history_repository.dart';
import 'package:cododoro/common/data_layer/persistent/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils.dart';

Duration calculateRemainingDayWorkTime(
    HistoryRepository historyRepository, Settings settings) {
  final todayIntervals = historyRepository.getTodayIntervals();

  final targetWorkingMinutes = Duration(minutes: settings.targetWorkingMinutes);

  return _calculateRemainingWorkTime(
      intervals: todayIntervals, targetWorkingDuration: targetWorkingMinutes);
}

Duration calculateRemainingWeekWorkTime(
    HistoryRepository historyRepository, Settings settings) {
  final sevenDaysIntervals =
      historyRepository.getWeekIntervals(weekStartDay: settings.weekStartDay);

  final targetWorkingMinutes =
      Duration(minutes: settings.targetWeeklyWorkingMinutes);

  return _calculateRemainingWorkTime(
      intervals: sevenDaysIntervals,
      targetWorkingDuration: targetWorkingMinutes);
}

int durationToIntervalsCount(Duration duration, Settings settings) {
  final intervalDuration = Duration(seconds: settings.workDurationSeconds);
  return (duration.inMinutes / intervalDuration.inMinutes).ceil();
}

Duration _calculateRemainingWorkTime(
    {required Iterable<StoredInterval> intervals,
    required Duration targetWorkingDuration}) {
  final Duration calculatedWorkDuration =
      calculateTimeForIntervalType(intervals, IntervalType.work);

  final Duration workTimeTillGoal =
      targetWorkingDuration - calculatedWorkDuration;

  return workTimeTillGoal;
}

bool isWorkTargetReachedFromHistoryRepo(
    HistoryRepository historyRepository, Settings settings) {
  return calculateRemainingDayWorkTime(historyRepository, settings) <=
      Duration(hours: 0);
}

bool isWorkTargetReachedFromSharedPrefs(SharedPreferences sharedPrefs) {
  return isWorkTargetReachedFromHistoryRepo(
      HistoryRepository(prefs: sharedPrefs), Settings(prefs: sharedPrefs));
}
