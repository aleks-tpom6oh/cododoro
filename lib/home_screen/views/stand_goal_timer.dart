import 'package:cododoro/common/cubit/elapsed_time_cubit.dart';
import 'package:cododoro/common/data_layer/persistent/history_repository.dart';
import 'package:cododoro/common/data_layer/persistent/settings.dart';
import 'package:cododoro/common/utils/stand_time_remaining.dart';
import 'package:cododoro/home_screen/dialogs/share_standing_goal_reached_dialog.dart';
import 'package:cododoro/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StandGoalTimer extends StatelessWidget {
  StandGoalTimer({Key? key, required this.standingDeskTrackingEnabled})
      : super(key: key);

  final bool standingDeskTrackingEnabled;

  @override
  Widget build(BuildContext context) {
    context.watch<ElapsedTimeCubit>();
    final historyRepository = context.read<HistoryRepository>();
    final settings = context.read<Settings>();

    Duration standTimeTillGoal =
        calculateRemainingStandTime(historyRepository, settings);

    bool standTargetReached() {
      return standTimeTillGoal <= Duration(hours: 0);
    }

    return standingDeskTrackingEnabled
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
