import 'dart:isolate';

import 'package:cododoro/common/cubit/elapsed_time_cubit.dart';
import 'package:cododoro/common/data_layer/timer_state_model.dart';
import 'package:cododoro/common/data_layer/timer_states.dart';
import 'package:cododoro/common/utils/is_day_change_on_tick.dart';
import 'package:cododoro/home_screen/views/day_work_rest_timer.dart';
import 'package:cododoro/home_screen/views/stand_goal_timer.dart';
import 'package:cododoro/home_screen/views/time_counter.dart';
import 'package:cododoro/home_screen/views/week_work_timer.dart';
import 'package:cododoro/main.dart';
import 'package:cododoro/common/data_layer/volume_controller.dart';

import 'package:cododoro/onboarding/onboarding_config.dart';
import 'package:cododoro/onboarding/onboarding_tour.dart';
import 'package:cododoro/home_screen/dialogs/rest_ideas_dialog.dart';
import 'package:cododoro/home_screen/views/sit_stand_button.dart';

import 'package:cododoro/home_screen/dialogs/standing_goal_reached_dialog.dart';
import 'package:cododoro/home_screen/dialogs/suggest_to_stand_dialog.dart';
import 'package:cododoro/home_screen/dialogs/work_ended_dialog.dart';
import 'package:cododoro_macos_module/main.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:cododoro/common/data_layer/persistent/history_repository.dart';
import 'package:cododoro/common/data_layer/persistent/notifications_schedule.dart';
import 'package:cododoro/common/data_layer/persistent/settings.dart';
import 'package:cododoro/home_screen/views/animated_fab.dart';
import 'package:cododoro/settings_screen/settings_screen_dialog.dart';
import 'package:cododoro/stats_screen/stats_screen.dart';
import 'package:cododoro/home_screen/views/duration_output.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:async';

import 'package:cododoro/home_screen/view_model/timer_screen_logic.dart'
    as logic;

import 'package:flutter/foundation.dart' show kIsWeb;

Isolate? _timerIsolate;
Timer? tickTimer;

class TimerScreen extends StatefulWidget {
  final void Function() showIdleScreen;

  const TimerScreen({Key? key, required this.showIdleScreen}) : super(key: key);

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  bool _isSoundOn = volumeController.isSoundOn;
  bool _isStanding = false;
  bool _initialButtonsExpended = false;

  OnboardingTour? _onboardingTour;

  AnimationController? _revealAnimation;

  void toggleSound() {
    setState(() {
      _isSoundOn = !_isSoundOn;
      volumeController.isSoundOn = _isSoundOn;
      logic.stopAllSounds();
    });
  }

  void _animateSessionInfo(Function action) {
    if (_revealAnimation != null) {
      _revealAnimation!.reverse().then((_) {
        _fadeInSessionInfo();
        action.call();
      });
    } else {
      action.call();
    }
  }

  void _fadeInSessionInfo() {
    _revealAnimation!.forward();
  }

  Timer? standingGoalReachedDialogDelayTimer;
  void _tick() {
    final timerModel = context.read<TimerStateModel>();
    final elapsedTimeCubit = BlocProvider.of<ElapsedTimeCubit>(context);
    final historyRepository = context.read<HistoryRepository>();
    final settings = context.read<Settings>();

    logic.tick(elapsedTimeCubit, timerModel, historyRepository, settings,
        historyRepository.prefs,
        isStanding: _isStanding,
        isDayChangeOnTick: IsDayChangeOnTick(), onReachedStandingGoal: () {
      standingGoalReachedDialogDelayTimer =
          new Timer(new Duration(seconds: 4), () async {
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return StandingGoalReachedDialog(onSit: () {
              setState(() {
                _isStanding = false;
                logic.stopStandingSession(historyRepository);
              });
            }, onSitAndTakeABreak: () {
              nextStage(elapsedTimeCubit, timerModel, historyRepository)();
              setState(() {
                _isStanding = false;
                logic.stopStandingSession(historyRepository);
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

  void initAnimations() {
    _revealAnimation = AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
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

    initAnimations();

    clearOldHistory();

    Future.delayed(Duration.zero, () {
      final onboardingConfig = OnboardingConfig();
      onboardingConfig.init().then((initializedOnboardingConfig) {
        _onboardingTour = OnboardingTour(initializedOnboardingConfig);
        _onboardingTour?.startOnboardingTour(context);

        final timerModel = context.read<TimerStateModel>();
        final elapsedTimeCubit = context.read<ElapsedTimeCubit>();

        final historyRepository = context.read<HistoryRepository>();

        logic.onOnboardingConfigLoaded(initializedOnboardingConfig,
            elapsedTimeCubit, timerModel, historyRepository);
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
              logic.stopStandingSession(history);
            });
          },
        ),
      ));
    }
  }

  void Function() nextStage(ElapsedTimeCubit elapsedTimeCubit,
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

      _animateSessionInfo(() {
        logic.nextStage(
            elapsedTimeCubit, timerModel, historyRepository, _isStanding);
      });
    };

    return nextStage;
  }

  void Function() onPleaseStandUpConfirmed(ElapsedTimeCubit elapsedTimeCubit,
      TimerStateModel timerModel, HistoryRepository historyRepository) {
    final result = () {
      nextStage(elapsedTimeCubit, timerModel, historyRepository)();
      if (!_isStanding) {
        try {
          setState(() {
            _isStanding = true;
          });
        } catch (e) {}
        logic.startStandingSessionByUser(historyRepository, timerModel);
      }
    };

    return result;
  }

  Widget proceedStageFab() {
    return FloatingActionButton(
      heroTag: "proceed-fab",
      onPressed: () {
        final timerModel = context.read<TimerStateModel>();
        final elapsedTimeCubit = BlocProvider.of<ElapsedTimeCubit>(context);
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
                        elapsedTimeCubit, timerModel, historyRepository),
                    onReject: nextStage(
                        elapsedTimeCubit, timerModel, historyRepository));
              },
            );
          } else {
            nextStage(elapsedTimeCubit, timerModel, historyRepository)();
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
        _animateSessionInfo(() {
          logic.pauseResume(watchTimerModel);
        });
      },
      child:
          watchTimerModel.isPaused ? Icon(Icons.play_arrow) : Icon(Icons.pause),
      backgroundColor:
          Theme.of(context).floatingActionButtonTheme.backgroundColor,
    );
  }

  Widget seeStatsButton() {
    return Container(
      margin: new EdgeInsets.only(top: 8),
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

    final watchTimerStateLogic = context.watch<TimerStateModel>();
    final settings = context.watch<Settings>();
    final historyRepository = context.read<HistoryRepository>();

    _initialButtonsExpended =
        watchTimerStateLogic.state != TimerStates.noSession;

    showMacOsNotificationsSnackbar(context);

    return Scaffold(
        backgroundColor: backgroundColor(context, watchTimerStateLogic),
        appBar: AppBar(
          title: const Text('Pomodoro Code'),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                DayWorkRestTimer(
                                    showIdleScreen: widget.showIdleScreen),
                                SizedBox(height: 8),
                                WeekWorkTimer(),
                              ],
                            ),
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
                              duration: settings.workDurationSeconds,
                              label: "💻"),
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
                                    logic.startStandingSessionByUser(
                                        historyRepository,
                                        watchTimerStateLogic);
                                  } else {
                                    logic
                                        .stopStandingSession(historyRepository);
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
                child: FadeTransition(
              opacity: _revealAnimation!,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  settings.showCuteCats
                      ? Image.asset(
                          logic.currentStateGifPath(watchTimerStateLogic),
                          height: 225.0,
                          width: 225.0,
                        )
                      : SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(stateLabel(watchTimerStateLogic),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.normal)),
                      ),
                      watchTimerStateLogic.isResting ||
                              watchTimerStateLogic.isChilling
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
                              child: Text("Exercises"))
                          : SizedBox(),
                    ],
                  ),
                  watchTimerStateLogic.isChilling
                      ? SizedBox(height: 44)
                      : TimerCounter(),
                ],
              ),
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
              _animateSessionInfo(() {
                var timerModel = context.read<TimerStateModel>();
                final elapsedTimeCubit =
                    BlocProvider.of<ElapsedTimeCubit>(context);
                final historyRepository = context.read<HistoryRepository>();
                logic.startWorkSession(
                    elapsedTimeCubit, timerModel, historyRepository);
                _onboardingTour?.moveToSecondOnboardingTourStep(context);
              });
            },
            onCollapse: () {
              _animateSessionInfo(() {
                final timerModel = context.read<TimerStateModel>();
                final elapsedTimeCubit =
                    BlocProvider.of<ElapsedTimeCubit>(context);

                final historyRepository = context.read<HistoryRepository>();
                logic.stopSession(
                    elapsedTimeCubit, timerModel, historyRepository);
              });
            },
            children: [proceedStageFab(), pauseResumeFab()]));
  }

  @override
  void dispose() {
    _timerIsolate?.kill();
    tickTimer?.cancel();
    logic.timeScreenDispose();
    standingGoalReachedDialogDelayTimer?.cancel();
    _revealAnimation!.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
