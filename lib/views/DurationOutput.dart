import 'package:flutter/material.dart';

class DurationOutput extends StatelessWidget {
  DurationOutput({Key? key, @required this.duration, this.label = "Duration"}) : super(key: key);

  final Future<int>? duration;
  final String label;

  @override
  Widget build(BuildContext context) {

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
              return Text(
                  snapshot.hasData
                      ? "${Duration(seconds: snapshot.data!).inMinutes}"
                      : snapshot.hasError
                          ? "${snapshot.error}"
                          : "Loading current work duration",
                  textAlign: TextAlign.center);
            }));
  }
}
