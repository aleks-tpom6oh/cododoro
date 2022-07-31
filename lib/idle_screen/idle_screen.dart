import 'dart:async';

import 'package:cododoro/data_layer/storage/ThemeSettings.dart';
import 'package:cododoro/viewlogic/WorkTimeRemaining.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdleScreen extends StatefulWidget {
  final SharedPreferences? sharedPrefs;
  final ThemeSetting themeSetting;
  final void Function() showTimerScreen;

  const IdleScreen(
      {Key? key,
      required this.sharedPrefs,
      required this.themeSetting,
      required this.showTimerScreen})
      : super(key: key);

  @override
  State<IdleScreen> createState() => _IdleScreenState();
}

class _IdleScreenState extends State<IdleScreen> {
  Timer? _newDayChecker;

  bool _workTargetReached = false;

  @override
  void initState() {
    super.initState();
    checkWorkTargetReached();
    _newDayChecker = Timer.periodic(Duration(minutes: 5), (Timer t) {
      checkWorkTargetReached();
    });
  }

  void checkWorkTargetReached() {
    setState(() {
      _workTargetReached = this.widget.sharedPrefs == null
          ? false
          : isWorkTargetReachedFromSharedPrefs(this.widget.sharedPrefs!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: _workTargetReached
                ? Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            "⛱\n\nYou've reached your working goal for today, now go get some rest to be productive tomorrow.",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 100,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Press the fire engine to go back to work',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w100,
                                  ),
                                ),
                                SizedBox(height: 2),
                                ElevatedButton(
                                  child: Text('🚒'),
                                  onPressed: () {
                                    this.widget.showTimerScreen.call();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Hello World"),
                      SizedBox(height: 24),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("It's "),
                          Text(
                            "${DateFormat('EEEE d MMMM y').format(DateTime.now())}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary:
                                this.widget.themeSetting == ThemeSetting.light
                                    ? const Color(0xFF272236)
                                    : const Color(0xFFFF756C),
                          ),
                          child: Text("Let's go"),
                          onPressed: () {
                            this.widget.showTimerScreen.call();
                          }),
                    ],
                  )));
  }

  @override
  void dispose() {
    super.dispose();
    _newDayChecker?.cancel();
  }
}
