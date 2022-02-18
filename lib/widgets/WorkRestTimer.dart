import 'package:cododoro/models/ElapsedTimeModel.dart';
import 'package:cododoro/storage/Settings.dart';
import 'package:cododoro/viewlogic/WorkTimeGoalEstimate.dart';
import 'package:cododoro/viewlogic/WorkTimeRemaining.dart';
import 'package:flutter/material.dart';
import 'package:cododoro/storage/HistoryRepository.dart';
import 'package:provider/provider.dart';
import 'package:cododoro/utils.dart';

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
    context.watch<ElapsedTimeModel>();

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
