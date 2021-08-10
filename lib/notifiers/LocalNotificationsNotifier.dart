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
  Future<void> notify(message) async {
    const IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(threadIdentifier: 'cododoro');
    const MacOSNotificationDetails macOSPlatformChannelSpecifics =
        MacOSNotificationDetails(threadIdentifier: 'cododoro');

    const String groupChannelId = 'cododoro';
    const String groupChannelName = 'time notifications';
    const String groupChannelDescription =
        'channel for cododoro time notifications';
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            groupChannelId, groupChannelName, groupChannelDescription,
            importance: Importance.max,
            priority: Priority.high,
            groupKey: 'com.android.cododoro.TIME_NOTIFICATION');

    const notificationDetails = NotificationDetails(
        iOS: iOSPlatformChannelSpecifics,
        macOS: macOSPlatformChannelSpecifics,
        android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, 'Cododoro', message, notificationDetails);
  }
}
