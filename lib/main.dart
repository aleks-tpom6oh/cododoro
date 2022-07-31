import 'dart:async';

import 'package:avo_inspector/avo_inspector.dart';
import 'package:cododoro/common/cubit/elapsed_time_cubit.dart';
import 'package:cododoro/common/data_layer/persistent/history_repository.dart';
import 'package:cododoro/common/data_layer/persistent/theme_settings.dart';
import 'package:cododoro/idle_screen/idle_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:mixpanel_analytics/mixpanel_analytics.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:platform_info/platform_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'common/data_layer/persistent/settings.dart';
import 'common/data_layer/timer_state_model.dart';
import 'home_screen/screen/timer_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();

  if (timeZoneName == "America/Buenos_Aires") {
    timeZoneName = "America/Argentina/Buenos_Aires";
  } else if (!tz.timeZoneDatabase.locations.containsKey(timeZoneName)) {
    timeZoneName = "Atlantic/Reykjavik";
  }

  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

MixpanelAnalytics? mixpanel;
AvoInspector? avoInspector;

Future<bool> mixpanelTrack(
    {required String eventName, Map<String, dynamic> params = const {}}) async {
  String? deviceId;
  try {
    deviceId = await PlatformDeviceId.getDeviceId;
  } on PlatformException {
    deviceId = 'Failed to get deviceId.';
  }

  final os = Platform.instance.operatingSystem.toString().split('.').last;

  return mixpanel
          ?.track(
              event: eventName,
              properties: {"distinct_id": deviceId, "OS": os}..addAll(params))
          .then((value) {
        avoInspector?.trackSchemaFromEvent(
            eventName: eventName, eventProperties: params);

        return value;
      }) ??
      Future.value(false);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _configureLocalTimeZone();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings();
  const MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  avoInspector = await AvoInspector.create(
      apiKey: "YwFVkbijwhINH1mv3JED",
      env: kReleaseMode ? AvoInspectorEnv.prod : AvoInspectorEnv.dev,
      appVersion: "1.0",
      appName: "Flutter test");

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeSettings themeSettings = ThemeSettings();

  bool isIdle = true;

  @override
  void initState() {
    mixpanel = MixpanelAnalytics(
        token: "e526e2811ef8cf92c6a18dcbc889f12b",
        verbose: false,
        shouldAnonymize: true,
        shaFn: (value) => value,
        onError: (e) {
          print("mixpanel error");
        });

    trackAppOpened();

    themeSettings.addListener(() {
      setState(() {
        _themeSetting = themeSettings.currentThemeSetting;
      });
    });

    themeSettings.init();

    super.initState();
  }

  void trackAppOpened() async {
    mixpanelTrack(eventName: 'App Opened');
  }

  ThemeSetting _themeSetting = ThemeSetting.system;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (BuildContext context,
            AsyncSnapshot<SharedPreferences> sharedPrefsSnapshot) {
          final sharedPrefs = sharedPrefsSnapshot.data;

          return sharedPrefs != null && !isIdle
              ? timerScreen(sharedPrefs)
              : idleScreen(sharedPrefs);
        });
  }

  MaterialApp idleScreen(SharedPreferences? sharedPrefs) {
    return MaterialApp(
        theme: _themeSetting == ThemeSetting.dark ? darkTheme : lightTheme,
        darkTheme: _themeSetting == ThemeSetting.light ? lightTheme : darkTheme,
        home: IdleScreen(
            sharedPrefs: sharedPrefs,
            themeSetting: _themeSetting,
            showTimerScreen: () {
              setState(() {
                isIdle = false;
              });
            }));
  }

  MultiProvider timerScreen(SharedPreferences sharedPrefs) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => TimerStateModel()),
          ChangeNotifierProvider(
              create: (context) => Settings(prefs: sharedPrefs)),
          ChangeNotifierProvider(
              create: (context) => HistoryRepository(prefs: sharedPrefs)),
          ChangeNotifierProvider(create: (context) => themeSettings)
        ],
        child: BlocProvider(
          create: (context) => ElapsedTimeCubit(),
          child: MaterialApp(
              title: 'Pomodoro Code',
              theme:
                  _themeSetting == ThemeSetting.dark ? darkTheme : lightTheme,
              darkTheme:
                  _themeSetting == ThemeSetting.light ? lightTheme : darkTheme,
              home: TimerScreen(showIdleScreen: () {
                setState(() {
                  isIdle = true;
                });
              })),
        ));
  }
}
