import 'package:cododoro/data_layer/storage/HistoryRepository.dart';
import 'package:cododoro/data_layer/storage/Settings.dart';

import '../utils.dart';

Duration calculateRemainingStandTime(
    HistoryRepository historyRepository, Settings settings) {
  final todayIntervals = historyRepository.getTodayIntervals();

  final targetStandingMinutes =
      Duration(minutes: settings.targetStandingMinutes);

  final Duration calculatedStandDuration =
      calculateTimeForIntervalType(todayIntervals, IntervalType.stand);

  final Duration standTimeTillGoal =
      targetStandingMinutes - calculatedStandDuration;

  return standTimeTillGoal;
}
