import 'package:flutter/material.dart';

class DurationOutput extends StatelessWidget {
  DurationOutput({Key? key, @required this.duration, this.label = "Duration"})
      : super(key: key);

  final Future<int>? duration;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(label),
        SizedBox(width: 16),
        timeOutput(),
      ],
    );
  }

  Widget timeOutput() {
    return Wrap(children: [
      FutureBuilder(
          future: duration,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            return SizedBox(
              width: 70,
              child: Text(
                  snapshot.hasData
                      ? "${Duration(seconds: snapshot.data!).inMinutes} mins"
                      : snapshot.hasError
                          ? "${snapshot.error}"
                          : "Loading current work duration",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis),
            );
          })
    ]);
  }
}
