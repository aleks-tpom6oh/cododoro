import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:cododoro/models/ElapsedTimeModel.dart';
import 'package:provider/provider.dart';

import 'storage/Settings.dart';
import 'views/TimerScreen.dart';
import 'models/TimerModel.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _configureLocalTimeZone();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings();
  const MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'cododoro',
        home: MultiProvider(providers: [
          ChangeNotifierProvider(create: (context) => TimerModel()),
          ChangeNotifierProvider(create: (context) => Settings()),
          ChangeNotifierProvider(create: (context) => ElapsedTimeModel()),
        ], child: TimerScreen()));
  }
}
