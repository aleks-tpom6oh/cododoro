import 'package:cododoro/common/cubit/elapsed_time_cubit.dart';
import 'package:cododoro/common/data_layer/persistent/history_repository.dart';
import 'package:cododoro/common/data_layer/persistent/settings.dart';
import 'package:cododoro/common/utils/work_time_remaining.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/utils/utils.dart';

class WeekWorkTimer extends StatelessWidget {
  WeekWorkTimer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final historyRepository = context.watch<HistoryRepository>();
    final settings = context.read<Settings>();
    context.watch<ElapsedTimeCubit>();

    final Iterable<StoredInterval>? sevenDaysIntervals =
        historyRepository.getWeekIntervals(weekStartDay: settings.weekStartDay);

    if (sevenDaysIntervals != null) {
      Duration workTimeTillWeekGoal =
          calculateRemainingWeekWorkTime(historyRepository, settings);

      int remainingIntervalsCount =
          durationToIntervalsCount(workTimeTillWeekGoal, settings);

      final Duration last7DaysWorkDuration =
          calculateTimeForIntervalType(sevenDaysIntervals, IntervalType.work);

      bool workTargetReached() {
        return workTimeTillWeekGoal <= Duration(hours: 0);
      }

      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Week stats"),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("💻 ${last7DaysWorkDuration.toShortHMString()}"),
                  workTargetReached()
                      ? Text("💻 Goal reached")
                      : remainingIntervalsCount > 1
                          ? Text("less than ${remainingIntervalsCount} 🍅 to go")
                          : Text(
                              "💻 ${workTimeTillWeekGoal.toShortHMString()} till goal"),
                ],
              ),
            ],
          ));
    }

    return SizedBox();
  }
}
