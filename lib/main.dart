
import 'package:flutter/material.dart';
import 'package:programadoro/models/ElapsedTimeModel.dart';
import 'package:programadoro/storage/NotificationsSchedule.dart';
import 'package:provider/provider.dart';

import 'storage/Settings.dart';
import 'views/TimerScreen.dart';
import 'models/TimerModel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'programadoro', home: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TimerModel()),
        ChangeNotifierProvider(create: (context) => Settings()),
        ChangeNotifierProvider(create: (context) => ElapsedTimeModel()),
      ],
      child: TimerScreen()));
  }
}




