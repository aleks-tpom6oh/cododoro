import 'package:cododoro/common/data_layer/persistent/theme_settings.dart';
import 'package:cododoro/settings_screen/standing_desk_settings_category.dart';
import 'package:cododoro/settings_screen/looks_settings_category.dart';
import 'package:flutter/material.dart';
import 'package:cododoro/common/data_layer/persistent/settings.dart';
import 'package:cododoro/settings_screen/notifications_settings_category.dart';
import 'package:cododoro/settings_screen/time_settings_category.dart';
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
    TextEditingController targetWorkMinutesInputController =
        TextEditingController();
    TextEditingController targetWeeklyWorkHoursInputController =
        TextEditingController();

    ThemeSettings themeSettings = context.read<ThemeSettings>();
    Settings settings = context.read<Settings>();

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
                LooksSettingsCategory(
                    themeSettings: themeSettings, settings: settings),
                TimeSettingsCategory(
                  settings: settings,
                  workDurationInputController: workDurationInputController,
                  restDurationInputController: restDurationInputController,
                  dayStartAdjustmentInputController:
                      dayStartAdjustmentInputController,
                  targetDayWorkMinutesInputController:
                      targetWorkMinutesInputController,
                  targetWeekWorkHoursInputController:
                      targetWeeklyWorkHoursInputController,
                ),
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
