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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text("Worked for $workMinutes minutes"),
                      Text("Rested for $restMinutes minutes"),
                      ListView(
                          padding: const EdgeInsets.all(8),
                          shrinkWrap: true,
                          children: //<Widget>[
                              (snapshot.data
                                      ?.map((e) => Container(
                                            height: 50,
                                            color: Colors.amber[600],
                                            child: Center(
                                                child: Text(
                                                    'You did ${e.type} for ${e.duration}')),
                                          ))
                                      .toList() ??
                                  <Widget>[]))
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
