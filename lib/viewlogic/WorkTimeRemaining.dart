import 'package:cododoro/storage/HistoryRepository.dart';
import 'package:cododoro/storage/Settings.dart';

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
