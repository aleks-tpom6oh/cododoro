import 'package:cododoro/models/VolumeController.dart';
import 'package:flutter/material.dart';
import 'package:cododoro/models/ElapsedTimeModel.dart';
import 'package:cododoro/storage/HistoryRepository.dart';
import 'package:cododoro/storage/NotificationsSchedule.dart';
import 'package:cododoro/storage/Settings.dart';
import 'package:cododoro/views/Controlls.dart';
import 'package:cododoro/views/settings/SettingsDialog.dart';
import 'package:cododoro/views/StatsScreen.dart';
import 'package:cododoro/views/DurationOutput.dart';
import 'package:provider/provider.dart';

import 'TimeCounter.dart';
import 'dart:async';

import '../models/TimerModel.dart';
import '../models/TimerStates.dart';
import '../viewlogic/TimerScreenLogic.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  bool _isSoundOn = volumeController.isSoundOn;

  void toggleSound() {
    setState(() {
      _isSoundOn = !_isSoundOn;
      volumeController.isSoundOn = _isSoundOn;
    });
  }

  void _tick() {
    var timerModel = context.read<TimerModel>();
    var elapsedTimeModel = context.read<ElapsedTimeModel>();

    tick(elapsedTimeModel, timerModel);
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _tick());
    clearOldHistory();
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
        pauseResume(watchTimerModel);
      },
      child:
          watchTimerModel.isPaused ? Icon(Icons.play_arrow) : Icon(Icons.pause),
      backgroundColor: Colors.pink,
    );
  }

  Widget seeStatsButton() {
    return Container(
      margin: new EdgeInsets.only(left: 8, top: 8),
      child: ElevatedButton(
        child: Text('See stats'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                      create: (context) => HistoryRepository(),
                      child: StatsScreen(),
                    )),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var watchTimerModel = context.watch<TimerModel>();
    var settings = context.watch<Settings>();
    return Scaffold(
        backgroundColor: backgroundColor(watchTimerModel),
        appBar: AppBar(
          title: const Text('cododoro'),
        ),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    seeStatsButton(),
                    Container(
                      margin: new EdgeInsets.only(right: 8, top: 8),
                      child: Column(
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
                                    return ChangeNotifierProvider(
                                      create: (context) =>
                                          NotificationSchedule(),
                                      child: SettingsDialog(settings: settings),
                                    );
                                  },
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: IconButton(
                      onPressed: () => {toggleSound()},
                      icon: Icon(_isSoundOn
                          ? Icons.volume_up_rounded
                          : Icons.volume_mute_rounded)),
                )
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

  @override
  void dispose() {
    timeScreenDispose();
    super.dispose();
  }
}
