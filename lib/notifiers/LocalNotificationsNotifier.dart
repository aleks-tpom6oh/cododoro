import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'BaseNotifier.dart';

class LocalNotificationsNotifier implements BaseNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void dispose() {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Future<void> notify(message, {String? soundPath, Duration delay = Duration.zero}) async {
    await Future.delayed(delay);
    const IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(threadIdentifier: 'cododoro', presentSound: false);
    const MacOSNotificationDetails macOSPlatformChannelSpecifics =
        MacOSNotificationDetails(threadIdentifier: 'cododoro', presentSound: false);

    const String groupChannelId = 'cododoro-2';
    const String groupChannelName = 'time notifications';
    const String groupChannelDescription =
        'channel for pomodoro code time notifications';
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            groupChannelId, groupChannelName, groupChannelDescription,
            importance: Importance.max,
            priority: Priority.high,
            groupKey: 'com.android.cododoro.TIME_NOTIFICATION',
            playSound: false);

    const notificationDetails = NotificationDetails(
        iOS: iOSPlatformChannelSpecifics,
        macOS: macOSPlatformChannelSpecifics,
        android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, 'Pomodoro Code', message, notificationDetails);
  }
}
