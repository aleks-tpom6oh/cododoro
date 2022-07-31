import 'package:flutter/material.dart';

class SitStandButton extends StatelessWidget {
  const SitStandButton(
      {Key? key,
      required this.standingDeskTrackingEnabled,
      required this.isStanding,
      required this.onPressed})
      : super(key: key);

  final bool standingDeskTrackingEnabled;
  final bool isStanding;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return standingDeskTrackingEnabled
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: ElevatedButton(
                child: Text(isStanding ? 'Standing' : 'Sitting'),
                style: ElevatedButton.styleFrom(
                    fixedSize: Size.fromWidth(134),
                    primary: isStanding
                        ? Colors.green
                        : Theme.of(context)
                            .floatingActionButtonTheme
                            .backgroundColor),
                onPressed: onPressed))
        : SizedBox(width: 150);
  }
}
