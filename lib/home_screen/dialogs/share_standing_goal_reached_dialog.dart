import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShareStandingGoalReachedDialog extends StatelessWidget {
  const ShareStandingGoalReachedDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SelectableText("I've reached my standing goal!"),
      actions: <Widget>[
        TextButton(
            onPressed: () async {
              await Clipboard.setData(
                  ClipboardData(text: "I've reached my standing goal!"));
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Copied')));
            },
            child: const Text("Copy to clipboard"))
      ],
    );
  }
}
