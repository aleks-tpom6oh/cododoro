import 'package:cododoro/common/cubit/elapsed_time_cubit.dart';
import 'package:cododoro/common/data_layer/persistent/history_repository.dart';
import 'package:cododoro/common/data_layer/persistent/settings.dart';
import 'package:cododoro/common/utils/work_time_goal_estimate.dart';
import 'package:cododoro/common/utils/work_time_remaining.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils.dart';

class WorkRestTimer extends StatelessWidget {
  final void Function() showIdleScreen;

  WorkRestTimer({Key? key, required this.showIdleScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final historyRepository = context.watch<HistoryRepository>();
    final settings = context.read<Settings>();
    context.watch<ElapsedTimeCubit>();

    final Iterable<StoredInterval>? todayIntervals =
        historyRepository.getTodayIntervals();

    if (todayIntervals != null) {
      final Duration todayWorkDuration =
          calculateTimeForIntervalType(todayIntervals, IntervalType.work);
      final Duration todayRestDuration =
          calculateTimeForIntervalType(todayIntervals, IntervalType.rest);

      Duration workTimeTillGoal =
          calculateRemainingWorkTime(historyRepository, settings);

      DateTime estimatedEndTime =
          estimateWorkGoalTime(historyRepository, settings, workTimeTillGoal);

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
                  workTargetReached()
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text("💻 Goal reached"),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          ?.color, // background
                                    ),
                                    onPressed: () {
                                      showIdleScreen.call();
                                    },
                                    child: Text("End work for today")),
                              )
                            ])
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "💻 ${workTimeTillGoal.toShortHMString()} till goal"),
                            Text(
                                "⏱ est. goal at ${estimatedEndTime.toHourMinutesTimestamp()}"),
                          ],
                        ),
                  Text("🏖 ${todayRestDuration.toShortHmsString()}"),
                ],
              ),
            ],
          ));
    }

    return SizedBox();
  }
}
