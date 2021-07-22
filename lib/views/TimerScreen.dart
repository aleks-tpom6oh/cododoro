import 'package:flutter/material.dart';
import 'package:programadoro/models/ElapsedTimeModel.dart';
import 'package:programadoro/views/StatsScreen.dart';
import 'package:programadoro/views/WorkDurationInput.dart';
import 'package:provider/provider.dart';

import 'TimeCounter.dart';
import 'dart:async';

import '../models/TimerModel.dart';
import '../models/TimerStates.dart';
import 'TimerScreenLogic.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  void _tick() {
    var timerModel = context.read<TimerModel>();
    var elapsedTimeModel = context.read<ElapsedTimeModel>();

    tick(elapsedTimeModel, timerModel);
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _tick());
  }

  String stateLabel(TimerModel watchTimerModel) {
    return watchTimerModel.state.toString();
  }

  Color backgroundColor(TimerModel watchTimerModel) {
    switch (watchTimerModel.state) {
      case TimerStates.sessionWorkingOvertime:
      case TimerStates.sessionRestingOvertime:
        {
          return Color(0xFFFFEBEE);
        }
      case TimerStates.sessionWorking:
      case TimerStates.sessionResting:
      case TimerStates.noSession:
        {
          return Color(0xFFFFFFFF);
        }
    }
  }

  Widget proceedStageFab() {
    return FloatingActionButton(
      onPressed: () {
        var timerModel = context.read<TimerModel>();
        var elapsedTimeModel = context.read<ElapsedTimeModel>();
        nextStage(elapsedTimeModel, timerModel);
      },
      child: Icon(Icons.play_arrow),
      backgroundColor: Colors.blue,
    );
  }

  Widget pauseResumeFab() {
    var watchTimerModel = context.read<TimerModel>();
    return FloatingActionButton(
      onPressed: () {
        watchTimerModel.pauseResume();
      },
      child: watchTimerModel.isRunning()
          ? Icon(Icons.pause_circle)
          : Icon(Icons.play_arrow),
      backgroundColor: Colors.blue,
    );
  }

  Widget floatingActionButtons(TimerModel watchTimerModel) {
    switch (watchTimerModel.state) {
      case TimerStates.sessionWorking:
      case TimerStates.sessionWorkingOvertime:
        {
          return Wrap(
            direction: Axis.vertical,
            children: <Widget>[
              Container(margin: EdgeInsets.all(10), child: pauseResumeFab()),
              Container(margin: EdgeInsets.all(10), child: proceedStageFab()),
            ],
          );
        }

      case TimerStates.sessionResting:
      case TimerStates.sessionRestingOvertime:
        {
          return Wrap(
            direction: Axis.vertical,
            children: <Widget>[
              Container(margin: EdgeInsets.all(10), child: pauseResumeFab()),
              Container(margin: EdgeInsets.all(10), child: proceedStageFab()),
            ],
          );
        }
      case TimerStates.noSession:
        {
          return proceedStageFab();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    var watchTimerModel = context.watch<TimerModel>();
    return Scaffold(
        backgroundColor: backgroundColor(watchTimerModel),
        appBar: AppBar(
          title: const Text('programadoro'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('See stats'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatsScreen()),
                );
              },
            ),
            WorkDurationInput(),
            Text(stateLabel(watchTimerModel)),
            TimerCounter(),
          ],
        )),
        floatingActionButton: floatingActionButtons(watchTimerModel));
  }
}
