import 'package:flutter/material.dart';
import 'package:programadoro/storage/Settings.dart';

class DurationsSettingsDialog extends StatelessWidget {
  const DurationsSettingsDialog(
      {Key? key,
      this.settings,
      this.workDurationInputController,
      this.restDurationInputController})
      : super(key: key);

  final Settings? settings;
  final TextEditingController? workDurationInputController;
  final TextEditingController? restDurationInputController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: <Widget>[
        FutureBuilder(
            future: this.settings?.restDuration,
            builder: (BuildContext context, AsyncSnapshot<int> restSnapshot) {
              return FutureBuilder(
                  future: this.settings?.workDuration,
                  builder:
                      (BuildContext context, AsyncSnapshot<int> workSnapshot) {
                    final workDuration = workSnapshot.hasData
                        ? "${Duration(seconds: workSnapshot.data!).inMinutes}"
                        : workSnapshot.hasError
                            ? "${workSnapshot.error}"
                            : "Loading current work duration";
                    this.workDurationInputController?.text = workDuration;
                    final restDuration = restSnapshot.hasData
                        ? "${Duration(seconds: restSnapshot.data!).inMinutes}"
                        : restSnapshot.hasError
                            ? "${restSnapshot.error}"
                            : "Loading current work duration";
                    this.restDurationInputController?.text = restDuration;
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: this.workDurationInputController,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                enabled: true,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    alignLabelWithHint: true,
                                    labelText: "Work",
                                    hintText: workDuration),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                final val =
                                    this.workDurationInputController?.text;
                                if (val != null) {
                                  print("Sublitted $val ${double.parse(val)}");
                                  this.settings?.setWorkDuration(
                                      (double.parse(val) * 60).toInt());
                                }
                              },
                              child: const Text('Apply'),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: this.restDurationInputController,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                enabled: true,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    alignLabelWithHint: true,
                                    labelText: "Rest",
                                    hintText: restDuration),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                final restVal =
                                    this.restDurationInputController?.text;
                                if (restVal != null) {
                                  print(
                                      "Sublitted $restVal ${double.parse(restVal)}");
                                  this.settings?.setRestDuration(
                                      (double.parse(restVal) * 60).toInt());
                                }
                              },
                              child: const Text('Apply'),
                            )
                          ],
                        )
                      ],
                    );
                  });
            }),
      ],
    );
  }
}
