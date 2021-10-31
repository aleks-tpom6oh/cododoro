import 'package:flutter/material.dart';
import 'package:cododoro/models/ElapsedTimeModel.dart';
import 'package:cododoro/utils.dart';
import 'package:provider/provider.dart';

class TimerCounter extends StatelessWidget {
  const TimerCounter({Key? key, this.elapsedTime: 0}) : super(key: key);

  final int elapsedTime;

  @override
  Widget build(BuildContext context) {
    var watchElapsedTimeModel =
        Provider.of<ElapsedTimeModel>(context, listen: true);
    
    return Text(
        stopwatchTime(Duration(seconds: watchElapsedTimeModel.elapsedTime)),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ));
  }
}
