import 'package:cododoro/storage/HistoryRepository.dart';
import 'package:cododoro/storage/Settings.dart';
import 'package:cododoro/viewlogic/StandTimeRemaining.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils.dart';

class WorkEndedDialog extends StatefulWidget {
  WorkEndedDialog({Key? key}) : super(key: key);

  @override
  _WorkEndedDialogState createState() => _WorkEndedDialogState();
}

class _WorkEndedDialogState extends State<WorkEndedDialog> {
  Duration? workDuration;
  Duration? standTimeTillGoal;

  @override
  void initState() {
    super.initState();

    HistoryRepository historyRepository = context.read<HistoryRepository>();
    Settings settings = context.read<Settings>();

    settings.standingDesk.then((hasStandingDesk) async {
      if (hasStandingDesk) {
        final newStandTimeTillGoal =
            await calculateRemainingStandTime(historyRepository, settings);
        setState(() {
          standTimeTillGoal = newStandTimeTillGoal;
        });
      }

      final todayIntervals = await historyRepository.getTodayIntervals();
      final Duration calculatedWorkDuration =
          calculateTimeForIntervalType(todayIntervals, IntervalType.work);

      setState(() {
        workDuration = calculatedWorkDuration;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyText1?.color;
    final timeColor = Theme.of(context).brightness == Brightness.dark
        ? Color(0xFFFF71DF)
        : Color(0xFF587FA8);

    return AlertDialog(
      title: Text("Congrats, another Cododoro completed!"),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: RichText(
                  text: TextSpan(
                      text: '💻 ${workDuration?.toHmsString()}',
                      style: TextStyle(
                          color: timeColor,
                          fontFamily: 'CourierPrime',
                          fontSize: 18),
                      children: [
                    TextSpan(
                      text: ' of pure work today',
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ])),
            ),
            standTimeTillGoal != null
                ? standTimeTillGoal! > Duration(hours: 0)
                    ? RichText(
                        text: TextSpan(
                            text: '🧍 ${standTimeTillGoal?.toMsString()}',
                            style: TextStyle(
                                color: timeColor,
                                fontFamily: 'CourierPrime',
                                fontSize: 18),
                            children: [
                            TextSpan(
                              text: ' left till your daily standing goal',
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                          ]))
                    : Text("🎉 You reached your standing goal!",
                        style: TextStyle(color: textColor, fontSize: 18))
                : SizedBox.shrink()
          ]),
    );
  }
}
