import 'package:flutter/material.dart';

class SuggestToStandDialog extends StatelessWidget {
  final void Function() onConfirm;
  final void Function() onReject;

  const SuggestToStandDialog(
      {Key? key, required this.onConfirm, required this.onReject})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("May I have your attention please?"),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("We have not counted enough standing time today yet,"),
              Text("so won't you please stand up?")
            ],
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text("Stand")),
        TextButton(
            onPressed: () {
              onReject();
              Navigator.pop(context);
            },
            child: const Text("Sit")),
      ],
    );
  }
}
