import 'package:cododoro/common/data_layer/persistent/history_repository.dart';
import 'package:cododoro/common/data_layer/persistent/settings.dart';

import 'utils.dart';

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
