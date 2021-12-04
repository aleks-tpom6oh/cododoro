import 'package:cododoro/storage/Settings.dart';
import 'package:cododoro/viewlogic/WorkTimeRemaining.dart';
import 'package:flutter/material.dart';
import 'package:cododoro/storage/HistoryRepository.dart';
import 'package:provider/provider.dart';
import 'package:cododoro/utils.dart';

class WorkRestTimer extends StatefulWidget {
  WorkRestTimer({Key? key}) : super(key: key);

  @override
  _WorkRestTimerState createState() => _WorkRestTimerState();
}

class _WorkRestTimerState extends State<WorkRestTimer> {
  @override
  Widget build(BuildContext context) {
    final historyRepository = context.watch<HistoryRepository>();
    final settings = context.read<Settings>();

    final Iterable<StoredInterval>? todayIntervals =
        historyRepository.getTodayIntervals();

    if (todayIntervals != null) {
      final Duration todayWorkDuration =
          calculateTimeForIntervalType(todayIntervals, IntervalType.work);
      final Duration todayRestDuration =
          calculateTimeForIntervalType(todayIntervals, IntervalType.rest);

      Duration workTimeTillGoal =
          calculateRemainingWorkTime(historyRepository, settings);

      bool workTargetReached() {
        return workTimeTillGoal <= Duration(hours: 0);
      }

      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
          child: Column(
            children: [
              const Text("Today stats"),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("💻 ${todayWorkDuration.toShortHmsString()}"),
                  Text(workTargetReached()
                      ? "💻 Goal reached"
                      : "💻 ${workTimeTillGoal.toShortHMString()} till goal"),
                  Text("🏖 ${todayRestDuration.toShortHmsString()}"),
                ],
              ),
            ],
          ));
    }

    return SizedBox();
  }
}
