import 'package:flutter/material.dart';

class StandingGoalReachedDialog extends StatelessWidget {
  final void Function() onSit;
  final void Function() onSitAndTakeABreak;

  const StandingGoalReachedDialog(
      {Key? key,
      required this.onSit,
      required this.onSitAndTakeABreak})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("🎉 Standing goal reached"),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Congratulations! We recommend to sit to keep the balance between sitting and standing."),
              SizedBox(height: 8,),
              Text("Also, take a break to celebrate reaching your goal!")
            ],
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              onSitAndTakeABreak();
            },
            child: const Text("Sit and take a break")),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              onSit();
            },
            child: const Text("Sit")),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Continue standing")),
      ],
    );
  }
}
