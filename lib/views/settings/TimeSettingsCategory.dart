import 'package:flutter/material.dart';
import 'package:cododoro/storage/Settings.dart';

class TimeSettingsCategory extends StatelessWidget {
  const TimeSettingsCategory({
    Key? key,
    required this.settings,
    required this.workDurationInputController,
    required this.restDurationInputController,
  }) : super(key: key);

  final Settings? settings;
  final TextEditingController workDurationInputController;
  final TextEditingController restDurationInputController;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: this.settings?.restDuration,
        builder: (BuildContext context, AsyncSnapshot<int> restSnapshot) {
          return FutureBuilder(
              future: this.settings?.workDuration,
              builder: (BuildContext context, AsyncSnapshot<int> workSnapshot) {
                final workDuration = workSnapshot.hasData
                    ? "${Duration(seconds: workSnapshot.data!).inMinutes}"
                    : workSnapshot.hasError
                        ? "${workSnapshot.error}"
                        : "Loading current work duration";
                workDurationInputController.text = workDuration;
                final restDuration = restSnapshot.hasData
                    ? "${Duration(seconds: restSnapshot.data!).inMinutes}"
                    : restSnapshot.hasError
                        ? "${restSnapshot.error}"
                        : "Loading current work duration";
                restDurationInputController.text = restDuration;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: Text(
                        "Time",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: workDurationInputController,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            enabled: true,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                alignLabelWithHint: true, labelText: "Work"),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            this.settings?.setWorkDuration((double.parse(
                                        workDurationInputController.text) *
                                    60)
                                .toInt());
                          },
                          child: const Text('Apply'),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: restDurationInputController,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            enabled: true,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                alignLabelWithHint: true, labelText: "Rest"),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            final restVal = restDurationInputController.text;
                            print(
                                "Sublitted $restVal ${double.parse(restVal)}");
                            this.settings?.setRestDuration(
                                (double.parse(restVal) * 60).toInt());
                          },
                          child: const Text('Apply'),
                        )
                      ],
                    ),
                  ],
                );
              });
        });
  }
}
