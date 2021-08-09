import 'package:flutter/material.dart';
import 'package:cododoro/storage/Settings.dart';
import 'package:cododoro/views/settings/NotificationsSettingsCategory.dart';
import 'package:cododoro/views/settings/TimeSettingsCategory.dart';


class SettingsDialog extends StatelessWidget {
  const SettingsDialog({Key? key, this.settings}) : super(key: key);

  final Settings? settings;

  @override
  Widget build(BuildContext context) {
    TextEditingController workDurationInputController = TextEditingController();
    TextEditingController restDurationInputController = TextEditingController();
    TextEditingController startNotificationDelayTimeInputController =
        TextEditingController();

    return AlertDialog(
      actions: <Widget>[
        Column(
          children: [
            TimeSettingsCategory(
                settings: settings,
                workDurationInputController: workDurationInputController,
                restDurationInputController: restDurationInputController),
            NotificationsSettingsCategory(
                startNotificationDelayTimeInputController:
                    startNotificationDelayTimeInputController)
          ],
        ),
      ],
    );
  }
}