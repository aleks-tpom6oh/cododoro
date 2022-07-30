import 'package:cododoro/data_layer/models/ElapsedTimeModel.dart';
import 'package:cododoro/data_layer/models/TimerStateModel.dart';
import 'package:cododoro/onboarding/OnboardingConfig.dart';
import 'package:cododoro/onboarding/OnboardingUtils.dart';
import 'package:cododoro/data_layer/storage/HistoryRepository.dart';
import 'package:cododoro/data_layer/storage/Settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewlogic/TimerScreenLogic.dart' as timerScreenLogic;

class OnboardingTour {
  final OnboardingConfig config;

  OnboardingTour(this.config);

  OverlayEntry? _overlayEntry;

  void startOnboardingTour(BuildContext context) async {
    switch (config.stepShown) {
      case 0:
        _showFirstStep(context);
        break;
      case 1:
        _showSecondStep(context);
        break;
      case 2:
        _showThirdStep(context);
        break;
      case 3:
        _showFourthStep(context);
        break;
      case 4:
        _showFifthStep(context);
        break;
      case 5:
        _showSixthStep(context);
        break;
      case 6:
        _showSeventhStep(context);
        break;
      case 7:
        _showCuteCats8thStep(context);
        break;
      default:
        return;
    }
  }

  void moveToSecondOnboardingTourStep(BuildContext context) {
    if (config.stepShown < 2) {
      _overlayEntry?.remove();
      _showSecondStep(context);
    }
  }

  void _showFirstStep(BuildContext context) async {
    if (config.stepShown >= 1) {
      return;
    }

    OverlayState? overlayState = Overlay.of(context);

    _overlayEntry = overlayEntryCreate(
        right: 70.0,
        bottom: 5.0,
        tooltipOffsetFrom: TooltipOffsetFrom.bottom,
        tooltipOffset: 34,
        child: Column(
          children: [
            Text(
              """When you open the app you are in unmetered chill state.
Press the timer button to go from chilling to work""",
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
            ),
            TextButton(
                onPressed: () {
                  var timerModel = context.read<TimerStateModel>();
                  var elapsedTimeModel = context.read<ElapsedTimeModel>();
                  final historyRepository = context.read<HistoryRepository>();
                  timerScreenLogic.startWorkSession(
                      elapsedTimeModel, timerModel, historyRepository);
                  _overlayEntry?.remove();

                  _showSecondStep(context);
                },
                child: const Text("Let's try it out"))
          ],
        ));

    if (_overlayEntry != null) {
      overlayState?.insert(_overlayEntry!);
    }
  }

  void _showSecondStep(BuildContext context) async {
    if (config.stepShown >= 2) {
      return;
    }

    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = overlayEntryCreate(
        right: 80.0,
        bottom: 5.0,
        tooltipOffsetFrom: TooltipOffsetFrom.bottom,
        tooltipOffset: 34,
        child: Column(
          children: [
            Text(
              """Pause at any point, the >| button switches from WORK to REST to WORK
and so on, press the end timer to go to the unmetered chill state""",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
            TextButton(
                onPressed: () {
                  _overlayEntry?.remove();

                  config.setStepShown(2);
                  _showThirdStep(context);
                },
                child: const Text("Got it!"))
          ],
        ));

    if (_overlayEntry != null) {
      overlayState?.insert(_overlayEntry!);
    }
  }

  void _showThirdStep(BuildContext context) async {
    if (config.stepShown >= 3) {
      return;
    }

    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = overlayEntryCreate(
      right: 110.0,
      top: 40.0,
      tooltipOffsetFrom: TooltipOffsetFrom.top,
      tooltipOffset: 34,
      child: Column(
        children: [
          Text(
            """Current work and rest target durations. You can have
your work/rest shorter or longer, when you go overtime
the app will start notifying you periodically""",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
          TextButton(
              onPressed: () {
                _overlayEntry?.remove();
                config.setStepShown(3);
                _showFourthStep(context);
              },
              child: const Text("Ok"))
        ],
      ),
    );

    if (_overlayEntry != null) {
      overlayState?.insert(_overlayEntry!);
    }
  }

  void _showFourthStep(BuildContext context) async {
    if (config.stepShown >= 4) {
      return;
    }

    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = overlayEntryCreate(
      right: 60.0,
      top: 5.0,
      tooltipOffsetFrom: TooltipOffsetFrom.top,
      tooltipOffset: 20,
      child: Column(
        children: [
          Text(
            """The settings button leads to the settings screen, where you can 
change the intervals, notifications delays and many more""",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
          TextButton(
              onPressed: () {
                _overlayEntry?.remove();
                config.setStepShown(4);
                _showFifthStep(context);
              },
              child: const Text("Cool!"))
        ],
      ),
    );

    if (_overlayEntry != null) {
      overlayState?.insert(_overlayEntry!);
    }
  }

  void _showFifthStep(BuildContext context) async {
    if (config.stepShown >= 5) {
      return;
    }

    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = overlayEntryCreate(
      right: 80.0,
      top: 80.0,
      tooltipOffsetFrom: TooltipOffsetFrom.top,
      tooltipOffset: 34,
      child: Column(
        children: [
          Text(
            """You can disable the audio notifications, useful when you
are on a meeting that goes over your target work duration""",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
          TextButton(
              onPressed: () {
                _overlayEntry?.remove();
                config.setStepShown(5);
                _showSixthStep(context);
              },
              child: const Text("Great!"))
        ],
      ),
    );

    if (_overlayEntry != null) {
      overlayState?.insert(_overlayEntry!);
    }
  }

  void _showSixthStep(BuildContext context) async {
    if (config.stepShown >= 6) {
      return;
    }

    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = overlayEntryCreate(
      right: 115.0,
      top: 122.0,
      tooltipOffsetFrom: TooltipOffsetFrom.top,
      tooltipOffset: 34,
      child: Column(
        children: [
          Text(
            """You can track your standing time with this toggle. The app will remind you
to stand up for your daily goal time, default is 100 minutes.

Do you want to use standing desk features?""",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    var settingsModel = context.read<Settings>();
                    settingsModel.setStandingDesk(true);

                    _overlayEntry?.remove();

                    config.setStepShown(6);
                    _showSeventhStep(context);
                  },
                  child: const Text("Yes")),
              SizedBox(width: 24),
              TextButton(
                  onPressed: () {
                    var settingsModel = context.read<Settings>();
                    settingsModel.setStandingDesk(false);

                    _overlayEntry?.remove();

                    config.setStepShown(6);
                    _showSeventhStep(context);
                  },
                  child: const Text("No")),
            ],
          )
        ],
      ),
    );

    if (_overlayEntry != null) {
      overlayState?.insert(_overlayEntry!);
    }
  }

  void _showSeventhStep(BuildContext context) async {
    if (config.stepShown >= 7) {
      return;
    }

    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = overlayEntryCreate(
      left: 100.0,
      top: 40.0,
      tooltipOffsetFrom: TooltipOffsetFrom.top,
      tooltipOffset: 34,
      tooltipDirection: TooltipDirection.left,
      child: Column(
        children: [
          Text(
            """On the stats screen you can view, add, swipe-delete 
and edit you total daily work, rest and standing time""",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
          TextButton(
              onPressed: () {
                _overlayEntry?.remove();

                config.setStepShown(7);
                _showCuteCats8thStep(context);
              },
              child: const Text("Got it!"))
        ],
      ),
    );

    if (_overlayEntry != null) {
      overlayState?.insert(_overlayEntry!);
    }
  }

  void _showCuteCats8thStep(BuildContext context) async {
    if (config.stepShown >= 8) {
      return;
    }

    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = overlayEntryCreate(
      left: MediaQuery.of(context).size.width * 0.14,
      top: MediaQuery.of(context).size.height / 2,
      tooltipDirection: TooltipDirection.no,
      tooltipOffset: 34,
      child: Column(
        children: [
          Text(
            """Would you like to see\ncute cats in the app?""",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    var settingsModel = context.read<Settings>();
                    settingsModel.setShowCuteCats(true);

                    _overlayEntry?.remove();

                    config.setStepShown(8);
                  },
                  child: const Text("Yes 😻")),
              SizedBox(width: 24),
              TextButton(
                  onPressed: () {
                    var settingsModel = context.read<Settings>();
                    settingsModel.setShowCuteCats(false);

                    _overlayEntry?.remove();

                    config.setStepShown(8);
                  },
                  child: const Text("No 🐕‍🦺")),
            ],
          )
        ],
      ),
    );

    if (_overlayEntry != null) {
      overlayState?.insert(_overlayEntry!);
    }
  }
}
