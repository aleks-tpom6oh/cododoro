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

/*     return FutureBuilder(
      future: historyRepository.getTodayIntervals(),
      builder: (BuildContext context,
          AsyncSnapshot<Iterable<StoredInterval>> todayIntervalsSnapshot) { */
        final Iterable<StoredInterval>? todayIntervals =
            historyRepository.getTodayIntervals();

        if (todayIntervals != null) {
          final Duration todayWorkDuration =
              calculateTimeForIntervalType(todayIntervals, IntervalType.work);
          final Duration todayRestDuration =
              calculateTimeForIntervalType(todayIntervals, IntervalType.rest);

          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
              child: Column(
                children: [
                  const Text("Today stats"),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("💻 ${todayWorkDuration.toShortMsString()}"),
                      Text("🏖 ${todayRestDuration.toShortMsString()}"),
                    ],
                  ),
                ],
              ));
        }

        return SizedBox();
/*       },
    ); */
  }
}
