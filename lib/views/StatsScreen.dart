import 'package:flutter/material.dart';
import 'package:programadoro/storage/HistoryRepository.dart';

extension Summer on Iterable<int> {
  int sum() {
    return (this.isEmpty)
        ? 0
        : this.reduce(
            (value, workIntervalDuration) => value + workIntervalDuration);
  }
}

int calculateTimeForIntervalType(
    Iterable<PomodoroInterval>? intervals, IntervalType intervalType) {
  return (intervals ?? [])
      .where((interval) => interval.type == intervalType)
      .map((interval) => interval.duration.inMinutes)
      .sum();
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todayIntervals = getTodayIntervals();

    return Scaffold(
      appBar: AppBar(
        title: Text("Stats Screen"),
      ),
      body: Center(
          child: FutureBuilder(
              future: todayIntervals,
              builder: (BuildContext context,
                  AsyncSnapshot<Iterable<PomodoroInterval>> snapshot) {
                if (snapshot.hasData) {
                  final workMinutes = calculateTimeForIntervalType(
                      snapshot.data, IntervalType.work);
                  final restMinutes = calculateTimeForIntervalType(
                      snapshot.data, IntervalType.rest);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Worked for $workMinutes minutes"),
                      Text("Rested for $restMinutes minutes"),
                      Text("${snapshot.data?.map((e) => {e.toJson()})}")
                    ],
                  );
                }
                return ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Go back!'),
                );
              })),
    );
  }
}
