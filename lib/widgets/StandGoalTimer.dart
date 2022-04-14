import 'package:cododoro/models/ElapsedTimeModel.dart';
import 'package:cododoro/storage/HistoryRepository.dart';
import 'package:cododoro/storage/Settings.dart';
import 'package:cododoro/viewlogic/StandTimeRemaining.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cododoro/utils.dart';

import 'dialogs/ShareStandingGoalReachedDialog.dart';

class StandGoalTimer extends StatefulWidget {
  StandGoalTimer({Key? key, required this.standingDeskTrackingEnabled})
      : super(key: key);

  final bool standingDeskTrackingEnabled;

  @override
  _StandGoalTimerState createState() => _StandGoalTimerState();
}

class _StandGoalTimerState extends State<StandGoalTimer> {
  @override
  Widget build(BuildContext context) {
    context.watch<ElapsedTimeModel>();
    final historyRepository = context.read<HistoryRepository>();
    final settings = context.read<Settings>();

    Duration standTimeTillGoal =
        calculateRemainingStandTime(historyRepository, settings);

    bool standTargetReached() {
      return standTimeTillGoal <= Duration(hours: 0);
    }

    return widget.standingDeskTrackingEnabled
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
            child: Column(
              children: standTargetReached()
                  ? [
                      Text("🎉 Goal reached"),
                      TextButton(
                          onPressed: () async {
                            await showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return ShareStandingGoalReachedDialog();
                              },
                            );
                          },
                          child: Text("Share"))
                    ]
                  : [
                      Text("🧍 ${standTimeTillGoal.toShortMsString()} left"),
                    ],
            ))
        : SizedBox(width: 150);
  }
}
