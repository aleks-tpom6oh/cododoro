import 'package:flutter/material.dart';

class DurationOutput extends StatelessWidget {
  DurationOutput({Key? key, @required this.duration, this.label = "Duration"}) : super(key: key);

  final Future<int>? duration; //= Settings().workDuration;
  final String label;

  @override
  Widget build(BuildContext context) {
    //var watchTimerModel = context.watch<TimerModel>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(label),
        timeInput(),
      ],
    );
  }

  Widget timeInput() {
    return SizedBox(
        width: 100,
        height: 20,
        child: FutureBuilder(
            future: duration,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              print("${Duration(seconds: snapshot.data!).inMinutes}");
              return Text(
                  snapshot.hasData
                      ? "${Duration(seconds: snapshot.data!).inMinutes}"
                      : snapshot.hasError
                          ? "${snapshot.error}"
                          : "Loading current work duration",
                  textAlign: TextAlign.center);

              /*       return TextField(
                maxLines: 1,
                textAlign: TextAlign.center,
                enabled: enabled,
                keyboardType: TextInputType.number,
                controller: TextEditingController(),
                decoration: InputDecoration(
                    hintText: snapshot.hasData
                        ? "${Duration(seconds: snapshot.data!).inMinutes}"
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
                        content: Text('You typed "$val"'),
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
              ); */
            }));
  }
}
