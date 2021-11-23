import 'package:flutter/material.dart';

class DurationOutput extends StatelessWidget {
  DurationOutput({Key? key, required this.duration, this.label = "Duration"})
      : super(key: key);

  final int duration;
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
      /* FutureBuilder(
          future: duration,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) { */
            /* return */ SizedBox(
              width: 70,
              child: Text("${Duration(seconds: duration).inMinutes} mins",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis),
            )
        /*   }) */
    ]);
  }
}
