import 'package:flutter/material.dart';
import 'package:programadoro/models/TimerModel.dart';
import 'package:programadoro/models/TimerStates.dart';
import 'package:programadoro/storage/Settings.dart';
import 'package:provider/provider.dart';

class WorkDurationInput extends StatelessWidget {
  const WorkDurationInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var watchTimerModel = context.watch<TimerModel>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text("Work duration"),
        timeInput(watchTimerModel),
      ],
    );
  }

  Widget timeInput(TimerModel watchTimerModel) {
    bool enabled = watchTimerModel.state == TimerStates.noSession;

    Future<int> _workDuration = Settings().workDuration;

    return SizedBox(
        width: 400,
        height: 80,
        child: FutureBuilder(
            future: _workDuration,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              return TextField(
                  maxLines: 1,
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(),
                  decoration: InputDecoration(
                      hintText: snapshot.hasData
                          ? "${snapshot.data}"
                          : snapshot.hasError
                              ? "${snapshot.error}"
                              : "Loading current work duration"),
                  onSubmitted: (String val) async {
                    print("Sublitted $val ${int.parse(val)}");
                    Settings().setWorkDuration(int.parse(val));

                    await showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Thanks!'),
                        content: Text(
                            'You typed "$val"'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  },
              );
            }));
  }
}
