import 'package:cododoro/storage/ThemeSettings.dart';
import 'package:cododoro/widgets/settings/StandingDeskSettingsCategory.dart';
import 'package:cododoro/widgets/settings/ThemeSettingsCategory.dart';
import 'package:flutter/material.dart';
import 'package:cododoro/storage/Settings.dart';
import 'package:cododoro/widgets/settings/NotificationsSettingsCategory.dart';
import 'package:cododoro/widgets/settings/TimeSettingsCategory.dart';
import 'package:provider/provider.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({Key? key, required this.settings}) : super(key: key);

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    TextEditingController workDurationInputController = TextEditingController();
    TextEditingController restDurationInputController = TextEditingController();
    TextEditingController dayStartAdjustmentInputController =
        TextEditingController();
    TextEditingController startNotificationDelayTimeInputController =
        TextEditingController();

    ThemeSettings themeSettings = context.read<ThemeSettings>();

    final scrollController = ScrollController();

    double width = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding:
          EdgeInsets.symmetric(horizontal: width * 0.07, vertical: 10),
      child: Scrollbar(
        controller: scrollController,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ThemeSettingsCategory(themeSettings: themeSettings),
                TimeSettingsCategory(
                    settings: settings,
                    workDurationInputController: workDurationInputController,
                    restDurationInputController: restDurationInputController,
                    dayStartAdjustmentInputController:
                        dayStartAdjustmentInputController),
                NotificationsSettingsCategory(
                    startNotificationDelayTimeInputController:
                        startNotificationDelayTimeInputController),
                StandingDeskSettingsCategory(settings: settings)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
