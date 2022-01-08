import 'package:cododoro/storage/HistoryRepository.dart';
import 'package:cododoro/storage/Settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';

Duration calculateRemainingWorkTime(
    HistoryRepository historyRepository, Settings settings) {
  final todayIntervals = historyRepository.getTodayIntervals();

  final targetWorkingMinutes = Duration(minutes: settings.targetWorkingMinutes);

  final Duration calculatedWorkDuration =
      calculateTimeForIntervalType(todayIntervals, IntervalType.work);

  final Duration workTimeTillGoal =
      targetWorkingMinutes - calculatedWorkDuration;

  return workTimeTillGoal;
}

bool isWorkTargetReachedFromHistoryRepo(
    HistoryRepository historyRepository, Settings settings) {
  return calculateRemainingWorkTime(historyRepository, settings) <=
      Duration(hours: 0);
}

bool isWorkTargetReachedFromSharedPrefs(SharedPreferences sharedPrefs) {
  return isWorkTargetReachedFromHistoryRepo(
      HistoryRepository(prefs: sharedPrefs), Settings(prefs: sharedPrefs));
}
