import 'package:flutter/material.dart';
import 'package:programadoro/models/ElapsedTimeModel.dart';
import 'package:programadoro/storage/Settings.dart';
import 'package:programadoro/views/Controlls.dart';
import 'package:programadoro/views/StatsScreen.dart';
import 'package:programadoro/views/DurationOutput.dart';
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
          return Color(0xFFF08080);
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
      heroTag: "proceed-fab",
      onPressed: () {
        var timerModel = context.read<TimerModel>();
        var elapsedTimeModel = context.read<ElapsedTimeModel>();
        nextStage(elapsedTimeModel, timerModel);
      },
      child: Icon(Icons.skip_next),
      backgroundColor: Colors.green,
    );
  }

  Widget pauseResumeFab() {
    var watchTimerModel = context.read<TimerModel>();
    return FloatingActionButton(
      heroTag: "pause-resume-fab",
      onPressed: () {
        watchTimerModel.pauseResume();
      },
      child:
          watchTimerModel.isPaused ? Icon(Icons.play_arrow) : Icon(Icons.pause),
      backgroundColor: Colors.pink,
    );
  }

  @override
  Widget build(BuildContext context) {
    var watchTimerModel = context.watch<TimerModel>();
    var settings = context.watch<Settings>();
    return Scaffold(
        backgroundColor: backgroundColor(watchTimerModel),
        appBar: AppBar(
          title: const Text('programadoro'),
        ),
        body: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: new EdgeInsets.only(left: 8),
                  child: ElevatedButton(
                    child: Text('See stats'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StatsScreen()),
                      );
                    },
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    DurationOutput(
                        duration: settings.workDuration,
                        label: "Work duration"),
                    DurationOutput(
                        duration: settings.restDuration,
                        label: "Rest duration"),
                    Container(
                      child: ElevatedButton(
                        child: Icon(Icons.settings),
                        onPressed: () async {
                          await showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              TextEditingController
                                  _workDurationInputController =
                                  TextEditingController();
                              TextEditingController
                                  _restDurationInputController =
                                  TextEditingController();
                              return AlertDialog(
                                actions: <Widget>[
                                  FutureBuilder(
                                      future: settings.restDuration,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<int> restSnapshot) {
                                        return FutureBuilder(
                                            future: settings.workDuration,
                                            builder: (BuildContext context,
                                                AsyncSnapshot<int>
                                                    workSnapshot) {
                                              final workDuration = workSnapshot
                                                      .hasData
                                                  ? "${Duration(seconds: workSnapshot.data!).inMinutes}"
                                                  : workSnapshot.hasError
                                                      ? "${workSnapshot.error}"
                                                      : "Loading current work duration";
                                              _workDurationInputController
                                                  .text = workDuration;
                                              final restDuration = restSnapshot
                                                      .hasData
                                                  ? "${Duration(seconds: restSnapshot.data!).inMinutes}"
                                                  : restSnapshot.hasError
                                                      ? "${restSnapshot.error}"
                                                      : "Loading current work duration";
                                              _restDurationInputController
                                                  .text = restDuration;
                                              return Column(
                                                children: [
                                                  TextField(
                                                    controller:
                                                        _workDurationInputController,
                                                    maxLines: 1,
                                                    textAlign: TextAlign.center,
                                                    enabled: true,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration: InputDecoration(
                                                        alignLabelWithHint:
                                                            true,
                                                        labelText: "Work",
                                                        hintText: workDuration),
                                                  ),
                                                  TextField(
                                                    controller:
                                                        _restDurationInputController,
                                                    maxLines: 1,
                                                    textAlign: TextAlign.center,
                                                    enabled: true,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration: InputDecoration(
                                                        alignLabelWithHint:
                                                            true,
                                                        labelText: "Rest",
                                                        hintText: restDuration),
                                                  )
                                                ],
                                              );
                                            });
                                      }),
                                  TextButton(
                                    onPressed: () {
                                      final val =
                                          _workDurationInputController.text;
                                      print(
                                          "Sublitted $val ${double.parse(val)}");
                                      settings.setWorkDuration(
                                          double.parse(val).toInt() * 60);

                                      final restVal =
                                          _restDurationInputController.text;
                                      print(
                                          "Sublitted $restVal ${double.parse(restVal)}");
                                      settings.setRestDuration(
                                          double.parse(restVal).toInt() * 60);

                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  )
                                ],
                              );
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
            Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(stateLabel(watchTimerModel)),
                TimerCounter(),
              ],
            ))
          ],
        ),
        floatingActionButton: FloatingActionButtons(
            expendIcon: Icon(Icons.timer),
            collapsedIcon: Icon(Icons.timer_off),
            distance: 112.0,
            onExpend: () {
              var timerModel = context.read<TimerModel>();
              var elapsedTimeModel = context.read<ElapsedTimeModel>();
              startSession(elapsedTimeModel, timerModel);
            },
            onCollapse: () {
              var timerModel = context.read<TimerModel>();
              var elapsedTimeModel = context.read<ElapsedTimeModel>();
              stopSession(elapsedTimeModel, timerModel);
            },
            children: [proceedStageFab(), pauseResumeFab()]));
  }
}
