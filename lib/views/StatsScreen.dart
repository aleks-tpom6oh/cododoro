import 'package:flutter/material.dart';
import 'package:programadoro/storage/HistoryRepository.dart';
import 'package:programadoro/timeutils.dart';

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
                  final workDuration = calculateTimeForIntervalType(
                      snapshot.data, IntervalType.work);
                  final restDuration = calculateTimeForIntervalType(
                      snapshot.data, IntervalType.rest);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Worked for ${workDuration.toHmsString()}"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Rested for ${restDuration.toHmsString()}"),
                      ),
                      Expanded(
                          child: ListView(
                              padding: const EdgeInsets.all(8),
                              children: //<Widget>[
                                  (snapshot.data
                                          ?.map(
                                            (e) => Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                  height: 50,
                                                  color: e.type ==
                                                          IntervalType.work
                                                      ? Colors.amber[600]
                                                      : Colors.cyan,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                        'You did ${e.type} for ${e.duration.toHmsString()}'),
                                                  )),
                                            ),
                                          )
                                          .toList() ??
                                      <Widget>[])))
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
