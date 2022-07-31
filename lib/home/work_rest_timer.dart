import 'package:cododoro/data_layer/cubit/elapsed_time_cubit.dart';
import 'package:cododoro/data_layer/storage/HistoryRepository.dart';
import 'package:cododoro/data_layer/storage/Settings.dart';
import 'package:cododoro/utils.dart';
import 'package:cododoro/viewlogic/WorkTimeGoalEstimate.dart';
import 'package:cododoro/viewlogic/WorkTimeRemaining.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkRestTimer extends StatefulWidget {
  final void Function() showIdleScreen;

  WorkRestTimer({Key? key, required this.showIdleScreen}) : super(key: key);

  @override
  _WorkRestTimerState createState() => _WorkRestTimerState();
}

class _WorkRestTimerState extends State<WorkRestTimer> {
  @override
  Widget build(BuildContext context) {
    final historyRepository = context.watch<HistoryRepository>();
    final settings = context.read<Settings>();
    BlocProvider.of<ElapsedTimeCubit>(context, listen: true);

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
                                      widget.showIdleScreen.call();
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
