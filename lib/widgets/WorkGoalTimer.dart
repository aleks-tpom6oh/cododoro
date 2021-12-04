import 'package:cododoro/storage/HistoryRepository.dart';
import 'package:cododoro/storage/Settings.dart';
import 'package:cododoro/utils.dart';
import 'package:cododoro/viewlogic/WorkTimeRemaining.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkGoalTimer extends StatefulWidget {
  WorkGoalTimer({Key? key}) : super(key: key);

  @override
  _WorkGoalTimerState createState() => _WorkGoalTimerState();
}

class _WorkGoalTimerState extends State<WorkGoalTimer> {
  @override
  Widget build(BuildContext context) {
    final historyRepository = context.watch<HistoryRepository>();
    final settings = context.read<Settings>();

    Duration workTimeTillGoal =
        calculateRemainingWorkTime(historyRepository, settings);

    bool workTargetReached() {
      return workTimeTillGoal <= Duration(hours: 0);
    }

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
        child: Text(workTargetReached()
            ? "🎉 Goal reached"
            : "🧍 ${workTimeTillGoal.toShortMsString()} left"));
  }
}
