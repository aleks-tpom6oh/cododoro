import 'package:flutter/material.dart';
import 'package:cododoro/common/data_layer/persistent/settings.dart';
import 'package:flutter/services.dart';

class TimeSettingsCategory extends StatefulWidget {
  const TimeSettingsCategory({
    Key? key,
    required this.settings,
    required this.workDurationInputController,
    required this.restDurationInputController,
    required this.dayStartAdjustmentInputController,
    required this.targetDayWorkMinutesInputController,
    required this.targetWeekWorkHoursInputController,
  }) : super(key: key);

  final Settings settings;
  final TextEditingController workDurationInputController;
  final TextEditingController targetDayWorkMinutesInputController;
  final TextEditingController targetWeekWorkHoursInputController;
  final TextEditingController restDurationInputController;
  final TextEditingController dayStartAdjustmentInputController;

  @override
  _TimeSettingsCategoryState createState() => _TimeSettingsCategoryState();
}

class _TimeSettingsCategoryState extends State<TimeSettingsCategory> {
  String dayStartTime = "unknown";

  void setDayStartTime(int dayHoursAdjustment) {
    dayStartTime = dayHoursAdjustment == 0
        ? "0.00"
        : dayHoursAdjustment == 12
            ? "12.00"
            : dayHoursAdjustment > 0
                ? "$dayHoursAdjustment.00"
                : "${24 + dayHoursAdjustment}.00";
  }

  @override
  Widget build(BuildContext context) {
    int dayHoursAdjustment = this.widget.settings.dayHoursOffset;
    setDayStartTime(dayHoursAdjustment);
    widget.dayStartAdjustmentInputController.text =
        dayHoursAdjustment.toString();

    final workDuration =
        "${Duration(seconds: this.widget.settings.workDurationSeconds).inMinutes}";
    widget.workDurationInputController.text = workDuration;
    final restDuration =
        "${Duration(seconds: this.widget.settings.restDuration).inMinutes}";
    widget.restDurationInputController.text = restDuration;

    final targetWorkingMinutes = widget.settings.targetWorkingMinutes;
    widget.targetDayWorkMinutesInputController.text = "$targetWorkingMinutes";

    final targetWeekWorkingHours =
        widget.settings.targetWeeklyWorkingMinutes / 60;
    widget.targetWeekWorkHoursInputController.text = "$targetWeekWorkingHours";

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Text(
            "Time Intervals",
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.workDurationInputController,
                maxLines: 1,
                textAlign: TextAlign.center,
                enabled: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                    alignLabelWithHint: true, labelText: "Work"),
              ),
            ),
            TextButton(
              onPressed: () {
                widget.settings.setWorkDurationSeconds(
                    (double.parse(widget.workDurationInputController.text) * 60)
                        .toInt());
              },
              child: const Text('Set'),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.targetDayWorkMinutesInputController,
                maxLines: 1,
                textAlign: TextAlign.center,
                enabled: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: "Target working minutes per day"),
              ),
            ),
            TextButton(
              onPressed: () {
                final newTaretWorkingTime = int.tryParse(
                    widget.targetDayWorkMinutesInputController.text);
                if (newTaretWorkingTime != null &&
                    newTaretWorkingTime > 0 &&
                    newTaretWorkingTime <= 720) {
                  widget.settings.setTargetWorkingMinutes(newTaretWorkingTime);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Use an integer from 1 to 720')));

                  if (newTaretWorkingTime != null &&
                      newTaretWorkingTime > 720) {
                    widget.settings.setTargetWorkingMinutes(720);
                    widget.targetDayWorkMinutesInputController.text = "720";
                  } else if (newTaretWorkingTime != null) {
                    widget.settings.setTargetWorkingMinutes(1);
                    widget.targetDayWorkMinutesInputController.text = "1";
                  }
                }
              },
              child: const Text('Set'),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.targetWeekWorkHoursInputController,
                maxLines: 1,
                textAlign: TextAlign.center,
                enabled: true,
                keyboardType: TextInputType.number,
                inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: "Target working hours per week"),
              ),
            ),
            TextButton(
              onPressed: () {
                final newWeekTargetWorkingTime = double.tryParse(
                    widget.targetWeekWorkHoursInputController.text);
                if (newWeekTargetWorkingTime != null &&
                    newWeekTargetWorkingTime > 0 &&
                    newWeekTargetWorkingTime <= 84) {
                  widget.settings.setTargetWeeklyWorkingMinutes(
                      (newWeekTargetWorkingTime * 60).ceil());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Use an integer from 1 to 84')));

                  if (newWeekTargetWorkingTime != null &&
                      newWeekTargetWorkingTime > 84) {
                    widget.settings.setTargetWeeklyWorkingMinutes(84 * 60);
                    widget.targetWeekWorkHoursInputController.text = "84";
                  } else if (newWeekTargetWorkingTime != null) {
                    widget.settings.setTargetWeeklyWorkingMinutes(1 * 60);
                    widget.targetWeekWorkHoursInputController.text = "1";
                  }
                }
              },
              child: const Text('Set'),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.restDurationInputController,
                maxLines: 1,
                textAlign: TextAlign.center,
                enabled: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                    alignLabelWithHint: true, labelText: "Rest"),
              ),
            ),
            TextButton(
              onPressed: () {
                final restVal = widget.restDurationInputController.text;
                widget.settings
                    .setRestDuration((double.parse(restVal) * 60).toInt());
              },
              child: const Text('Set'),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.dayStartAdjustmentInputController,
                maxLines: 1,
                textAlign: TextAlign.center,
                enabled: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.singleLineFormatter
                ],
                decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: "Day start adjustment"),
              ),
            ),
            Text("hours"),
            TextButton(
              onPressed: () {
                final dayStartAdjustmentVal =
                    widget.dayStartAdjustmentInputController.text;
                final newDayStartAdjustment =
                    int.tryParse(dayStartAdjustmentVal);
                if (newDayStartAdjustment != null &&
                    newDayStartAdjustment > -12 &&
                    newDayStartAdjustment <= 12) {
                  widget.settings.setDayHoursOffset(newDayStartAdjustment);
                  setState(() {
                    setDayStartTime(newDayStartAdjustment);
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Use an integer from -11 to 12.')));

                  if (newDayStartAdjustment != null &&
                      newDayStartAdjustment > 12) {
                    widget.settings.setDayHoursOffset(12);
                    widget.dayStartAdjustmentInputController.text = "12";
                  } else if (newDayStartAdjustment != null) {
                    widget.settings.setDayHoursOffset(-11);
                    widget.dayStartAdjustmentInputController.text = "-11";
                  }
                }
              },
              child: const Text('Set'),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text("Day starts at $dayStartTime"),
        ),
      ],
    );
  }
}
