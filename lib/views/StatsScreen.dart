import 'package:flutter/material.dart';
import 'package:programadoro/storage/HistoryRepository.dart';

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
                  return Text("${snapshot.data?.map((e) => {e.toJson()})}");
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
