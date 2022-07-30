import 'package:cododoro/data_layer/storage/Settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StandingDeskSettingsCategory extends StatefulWidget {
  const StandingDeskSettingsCategory({
    Key? key,
    required this.settings,
  }) : super(key: key);

  final Settings settings;

  @override
  _StandingDeskSettingsCategoryState createState() =>
      _StandingDeskSettingsCategoryState();
}

class _StandingDeskSettingsCategoryState
    extends State<StandingDeskSettingsCategory> {
  bool? standingDeskEnabled;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.greenAccent;
      }

      return Colors.grey;
    }

    final targetStandingTimeTextController = new TextEditingController();
    final standingReminderHourTextController = new TextEditingController();

    standingDeskEnabled = this.widget.settings.standingDesk;
    final targetStandingTime = this.widget.settings.targetStandingMinutes;
    final standingReminderHour = this.widget.settings.standingReminderHour;

    targetStandingTimeTextController.text = targetStandingTime.toString();
    standingReminderHourTextController.text = standingReminderHour.toString();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Text(
            "Health",
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            Checkbox(
              checkColor: Colors.white,
              fillColor: MaterialStateProperty.resolveWith(getColor),
              value: standingDeskEnabled,
              onChanged: (bool? value) {
                if (value != null) {
                  widget.settings.setStandingDesk(value);
                  setState(() {
                    standingDeskEnabled = value;
                  });
                }
              },
            ),
            Text("Track standing desk usage"),
          ],
        ),
        Row(children: [
          standingDeskEnabled == true
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      controller: targetStandingTimeTextController,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      enabled: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: "Terget standing minutes per day"),
                    ),
                  ),
                )
              : SizedBox(),
          standingDeskEnabled == true
              ? TextButton(
                  onPressed: () {
                    final newTaretStandingTime =
                        int.tryParse(targetStandingTimeTextController.text);
                    if (newTaretStandingTime != null &&
                        newTaretStandingTime > 0 &&
                        newTaretStandingTime <= 600) {
                      widget.settings
                          .setTargetStandingMinutes(newTaretStandingTime);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Use an integer from 1 to 600')));

                      if (newTaretStandingTime != null &&
                          newTaretStandingTime > 600) {
                        widget.settings.setTargetStandingMinutes(600);
                        targetStandingTimeTextController.text = "600";
                      } else if (newTaretStandingTime != null) {
                        widget.settings.setTargetStandingMinutes(1);
                        targetStandingTimeTextController.text = "1";
                      }
                    }
                  },
                  child: const Text('Set'),
                )
              : SizedBox(
                  height: 51,
                )
        ]),
        Row(children: [
          standingDeskEnabled == true
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      controller: standingReminderHourTextController,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      enabled: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: "Remind to stand if standing goal is not met after HH:00 hour"),
                    ),
                  ),
                )
              : SizedBox(),
          standingDeskEnabled == true
              ? TextButton(
                  onPressed: () {
                    final newStandingReminderHour =
                        int.tryParse(standingReminderHourTextController.text);
                    if (newStandingReminderHour != null &&
                        newStandingReminderHour > 0 &&
                        newStandingReminderHour <= 23) {
                      widget.settings
                          .setStandingReminderHour(newStandingReminderHour);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Use hour between 0 and 23')));

                      if (newStandingReminderHour != null &&
                          newStandingReminderHour > 23) {
                        widget.settings.setStandingReminderHour(23);
                        standingReminderHourTextController.text = "23";
                      } else if (newStandingReminderHour != null) {
                        widget.settings.setStandingReminderHour(0);
                        standingReminderHourTextController.text = "0";
                      }
                    }
                  },
                  child: const Text('Set'),
                )
              : SizedBox(
                  height: 51,
                )
        ]),
      ],
    );
  }
}
