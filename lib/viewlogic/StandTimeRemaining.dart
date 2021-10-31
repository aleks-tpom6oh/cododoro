import 'package:cododoro/storage/HistoryRepository.dart';
import 'package:cododoro/storage/Settings.dart';

import '../utils.dart';

Future<Duration> calculateRemainingStandTime(
    HistoryRepository historyRepository, Settings settings) {
  return historyRepository.getTodayIntervals().then((todayIntervals) async {
    final targetStandingMinutes =
        Duration(minutes: await settings.targetStandingMinutes);

    final Duration calculatedStandDuration =
        calculateTimeForIntervalType(todayIntervals, IntervalType.stand);

    final Duration standTimeTillGoal =
        targetStandingMinutes - calculatedStandDuration;

    return standTimeTillGoal;
  });
}
