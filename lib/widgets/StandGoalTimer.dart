import 'package:cododoro/storage/HistoryRepository.dart';
import 'package:cododoro/storage/Settings.dart';
import 'package:cododoro/viewlogic/StandTimeRemaining.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cododoro/utils.dart';

class StandGoalTimer extends StatefulWidget {
  StandGoalTimer({Key? key, required this.standingDeskTrackingEnabled})
      : super(key: key);

  final Future<bool>? standingDeskTrackingEnabled;

  @override
  _StandGoalTimerState createState() => _StandGoalTimerState();
}

class _StandGoalTimerState extends State<StandGoalTimer> {
  @override
  Widget build(BuildContext context) {
    final historyRepository = context.watch<HistoryRepository>();
    final settings = context.read<Settings>();

    return FutureBuilder<Duration>(
        future: calculateRemainingStandTime(historyRepository, settings),
        builder: (context, remainingStandingTimeSnapshot) {
          return FutureBuilder(
              future: widget.standingDeskTrackingEnabled,
              builder: (BuildContext context,
                  AsyncSnapshot<bool> standingEnabledSnapshot) {
                Duration? standTimeTillGoal = remainingStandingTimeSnapshot.data;

                bool standTargetReached() {
                  return standTimeTillGoal != null &&
                      standTimeTillGoal <= Duration(hours: 0);
                }

                return standingEnabledSnapshot.hasData &&
                        standingEnabledSnapshot.data == true
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 8.0),
                        child: Text(standTargetReached()
                            ? "🎉 Goal reached"
                            : "🧍 ${standTimeTillGoal?.toShortMsString()} left"))
                    : SizedBox(width: 150);
              });
        });
  }
}
