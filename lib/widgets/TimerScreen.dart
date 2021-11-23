import 'dart:isolate';

import 'package:cododoro/main.dart';
import 'package:cododoro/models/VolumeController.dart';
import 'package:cododoro/onboarding/OnboardingConfig.dart';
import 'package:cododoro/onboarding/OnboardingTour.dart';
import 'package:cododoro/widgets/dialogs/RestIdeasDialog.dart';
import 'package:cododoro/widgets/SitStandButton.dart';
import 'package:cododoro/widgets/StandGoalTimer.dart';
import 'package:cododoro/widgets/dialogs/StandingGoalReachedDialog.dart';
import 'package:cododoro/widgets/dialogs/SuggestToStandDialog.dart';
import 'package:cododoro/widgets/dialogs/WorkEndedDialog.dart';
import 'package:cododoro_macos_module/main.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:cododoro/models/ElapsedTimeModel.dart';
import 'package:cododoro/storage/HistoryRepository.dart';
import 'package:cododoro/storage/NotificationsSchedule.dart';
import 'package:cododoro/storage/Settings.dart';
import 'package:cododoro/widgets/views/Controlls.dart';
import 'package:cododoro/widgets/settings/SettingsDialog.dart';
import 'package:cododoro/widgets/StatsScreen.dart';
import 'package:cododoro/widgets/DurationOutput.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'TimeCounter.dart';
import 'dart:async';

import '../models/TimerModel.dart';
import '../models/TimerStates.dart';
import '../viewlogic/TimerScreenLogic.dart' as logic;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'WorkRestTimer.dart';

Isolate? _timerIsolate;
Timer? tickTimer;

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isSoundOn = volumeController.isSoundOn;
  bool _isStanding = false;
  bool _initialButtonsExpended = false;

  OnboardingTour? _onboardingTour;

  void toggleSound() {
    setState(() {
      _isSoundOn = !_isSoundOn;
      volumeController.isSoundOn = _isSoundOn;
    });
  }

  Timer? standingGoalReachedDialogDelayTimer;
  void _tick() {
    final timerModel = context.read<TimerStateModel>();
    final elapsedTimeModel = context.read<ElapsedTimeModel>();
    final historyRepository = context.read<HistoryRepository>();
    final settings = context.read<Settings>();

    logic.tick(elapsedTimeModel, timerModel, historyRepository, settings,
        isStanding: _isStanding, onReachedStandingGoal: () {
      standingGoalReachedDialogDelayTimer =
          new Timer(new Duration(seconds: 4), () async {
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return StandingGoalReachedDialog(onSit: () {
              setState(() {
                _isStanding = false;
                logic.stopStanding(historyRepository);
              });
            }, onSitAndTakeABreak: () {
              nextStage(
                  elapsedTimeModel, timerModel, historyRepository)();
              setState(() {
                _isStanding = false;
                logic.stopStanding(historyRepository);
              });
            });
          },
        );
      });
    });
  }

  Future spawnIsolate() async {
    ReceivePort _receivePort = ReceivePort();
    _timerIsolate = await Isolate.spawn(timerIsolate, _receivePort.sendPort,
        debugName: "timerIsolate");
    _receivePort.listen(
      (message) {
        _tick();
      },
    );
  }

  static void timerIsolate(SendPort sendPort) {
    Timer.periodic(
        Duration(milliseconds: 100), (Timer t) => sendPort.send("tick"));
  }

  @override
  void initState() {
    logic.timerScreenInitState();

    if (!kIsWeb) {
      spawnIsolate();
    } else {
      tickTimer =
          Timer.periodic(Duration(milliseconds: 100), (Timer t) => _tick());
    }

    super.initState();
    clearOldHistory();

    Future.delayed(Duration.zero, () {
      final onboardingConfig = OnboardingConfig();
      onboardingConfig.init().then((initializedOnboardingConfig) {
        _onboardingTour = OnboardingTour(initializedOnboardingConfig);
        _onboardingTour?.startOnboardingTour(context);
      });
    });
  }

  String stateLabel(TimerStateModel watchTimerModel) {
    return logic.currentSessionName(watchTimerModel);
  }

  Color backgroundColor(BuildContext context, TimerStateModel watchTimerModel) {
    switch (watchTimerModel.state) {
      case TimerStates.sessionWorkingOvertime:
      case TimerStates.sessionRestingOvertime:
        {
          return Theme.of(context).brightness == Brightness.dark
              ? Color(0xFF9B111E)
              : Color(0xFFF08080);
        }
      case TimerStates.sessionWorking:
      case TimerStates.sessionResting:
      case TimerStates.noSession:
        {
          return Theme.of(context).scaffoldBackgroundColor;
        }
    }
  }

  void _maybeAskIfStillStanding(timerModel, history) {
    if (logic.shouldAskStillStanding(_isStanding, timerModel)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Still standing?'),
        duration: Duration(seconds: 10),
        action: SnackBarAction(
          label: "I'm sitting",
          onPressed: () {
            setState(() {
              _isStanding = false;
              logic.stopStanding(history);
            });
          },
        ),
      ));
    }
  }

  void Function() nextStage(ElapsedTimeModel elapsedTimeModel,
      TimerStateModel timerModel, HistoryRepository historyRepository) {
    final nextStage = () {
      if (logic.shouldShowWorkEndedDialogOnNextStageClick(timerModel)) {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return WorkEndedDialog();
          },
        );
      }

      logic.nextStage(elapsedTimeModel, timerModel, historyRepository);
    };

    return nextStage;
  }

  Future<void> Function() onPleaseStandUpConfirmed(
      ElapsedTimeModel elapsedTimeModel,
      TimerStateModel timerModel,
      HistoryRepository historyRepository) {
    final result = () async {
      if (!_isStanding) {
        try {
          setState(() {
            _isStanding = true;
          });
        } catch (e) {}
        logic.startStanding(historyRepository, timerModel);
      }
      nextStage(elapsedTimeModel, timerModel, historyRepository)();
    };

    return result;
  }

  Widget proceedStageFab() {
    return FloatingActionButton(
      heroTag: "proceed-fab",
      onPressed: () {
        final timerModel = context.read<TimerStateModel>();
        final elapsedTimeModel = context.read<ElapsedTimeModel>();
        final historyRepository = context.read<HistoryRepository>();
        final settings = context.read<Settings>();

        _maybeAskIfStillStanding(timerModel, historyRepository);

        logic.maybeSuggestStanding(
            _isStanding, timerModel, historyRepository, settings,
            (suggestStanding) async {
          if (suggestStanding) {
            await showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return SuggestToStandDialog(
                    onConfirm: onPleaseStandUpConfirmed(
                        elapsedTimeModel, timerModel, historyRepository),
                    onReject: nextStage(
                        elapsedTimeModel, timerModel, historyRepository));
              },
            );
          } else {
            nextStage(elapsedTimeModel, timerModel, historyRepository)();
          }
        });
      },
      child: Icon(Icons.skip_next),
      backgroundColor: Theme.of(context).textTheme.bodyText1?.color,
    );
  }

  Widget pauseResumeFab() {
    var watchTimerModel = context.read<TimerStateModel>();

    return FloatingActionButton(
      heroTag: "pause-resume-fab",
      onPressed: () {
        logic.pauseResume(watchTimerModel);
      },
      child:
          watchTimerModel.isPaused ? Icon(Icons.play_arrow) : Icon(Icons.pause),
      backgroundColor:
          Theme.of(context).floatingActionButtonTheme.backgroundColor,
    );
  }

  Widget seeStatsButton() {
    return Container(
      margin: new EdgeInsets.only(left: 8, top: 8),
      child: ElevatedButton(
        child: Text('View stats'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StatsScreen()),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final watchTimerStateModel = context.watch<TimerStateModel>();
    final settings = context.watch<Settings>();
    final historyRepository = context.read<HistoryRepository>();

    _initialButtonsExpended = watchTimerStateModel.state != TimerStates.noSession;

    showMacOsNotificationsSnackbar(context);

    return Scaffold(
        backgroundColor: backgroundColor(context, watchTimerStateModel),
        appBar: AppBar(
          title: const Text('cododoro'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Icon(Icons.settings),
                onPressed: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return ChangeNotifierProvider(
                        create: (context) => NotificationSchedule(),
                        child: SettingsDialog(settings: settings),
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
                    Container(
                        margin: new EdgeInsets.only(right: 8, top: 8),
                        child: Column(
                          children: [
                            seeStatsButton(),
                            SizedBox(height: 8),
                            WorkRestTimer(),
                          ],
                        )),
                    Container(
                      margin: new EdgeInsets.only(right: 8, top: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Intervals"),
                          DurationOutput(
                              duration: settings.workDuration, label: "💻"),
                          DurationOutput(
                              duration: settings.restDuration, label: "🏖"),
                          IconButton(
                              onPressed: () => {toggleSound()},
                              icon: Icon(_isSoundOn
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_mute_rounded)),
                          SitStandButton(
                              standingDeskTrackingEnabled:
                                  settings.standingDesk,
                              isStanding: _isStanding,
                              onPressed: () {
                                setState(() {
                                  _isStanding = !_isStanding;

                                  if (_isStanding) {
                                    logic.startStanding(
                                        historyRepository, watchTimerStateModel);
                                  } else {
                                    logic.stopStanding(historyRepository);
                                  }
                                });
                              }),
                          StandGoalTimer(
                              standingDeskTrackingEnabled:
                                  settings.standingDesk),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  logic.currentStateGifPath(watchTimerStateModel),
                  height: 225.0,
                  width: 225.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(stateLabel(watchTimerStateModel),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.normal)),
                    ),
                    watchTimerStateModel.isResting
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  ?.color, // background
                            ),
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return RestIdeasDialog();
                                },
                              );
                            },
                            child: Text("Ideas"))
                        : SizedBox(),
                  ],
                ),
                TimerCounter(),
              ],
            )),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    mixpanelTrack(
                        eventName: "App Feedback Clicked", params: {});
                    launch(
                        'https://twitter.com/messages/compose?recipient_id=1378061147119685633');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Feedback "),
                      Image.asset("assets/images/twitter.png",
                          height: 25.0, width: 25.0)
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: logic.confetti,
                emissionFrequency: 0.05,
                blastDirectionality: BlastDirectionality.explosive,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButtons(
            initiallyExpended: _initialButtonsExpended,
            expendIcon: Icon(Icons.timer),
            collapsedIcon: Icon(Icons.timer_off),
            distance: 112.0,
            onExpand: () {
              var timerModel = context.read<TimerStateModel>();
              var elapsedTimeModel = context.read<ElapsedTimeModel>();
              final historyRepository = context.read<HistoryRepository>();
              logic.startSession(
                  elapsedTimeModel, timerModel, historyRepository);
              _onboardingTour?.moveToSecondOnboardingTourStep(context);
            },
            onCollapse: () {
              final timerModel = context.read<TimerStateModel>();
              final elapsedTimeModel = context.read<ElapsedTimeModel>();
              final historyRepository = context.read<HistoryRepository>();
              logic.stopSession(
                  elapsedTimeModel, timerModel, historyRepository);
            },
            children: [proceedStageFab(), pauseResumeFab()]));
  }

  @override
  void dispose() {
    _timerIsolate?.kill();
    tickTimer?.cancel();
    logic.timeScreenDispose();
    standingGoalReachedDialogDelayTimer?.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
