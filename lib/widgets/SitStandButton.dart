import 'package:flutter/material.dart';

class SitStandButton extends StatefulWidget {
  const SitStandButton(
      {Key? key,
      required this.standingDeskTrackingEnabled,
      required this.isStanding,
      required this.onPressed})
      : super(key: key);

  final Future<bool>? standingDeskTrackingEnabled;
  final bool isStanding;
  final void Function() onPressed;

  @override
  State<SitStandButton> createState() => _SitStandButtonState();
}

class _SitStandButtonState extends State<SitStandButton> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.standingDeskTrackingEnabled,
        builder: (BuildContext context,
            AsyncSnapshot<bool> standingEnabledSnapshot) {
          return standingEnabledSnapshot.hasData &&
                  standingEnabledSnapshot.data == true
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 8.0),
                  child: ElevatedButton(
                      child: Text(widget.isStanding ? 'Standing' : 'Sitting'),
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size.fromWidth(134),
                          primary: widget.isStanding
                              ? Colors.green
                              : Theme.of(context)
                                  .floatingActionButtonTheme
                                  .backgroundColor),
                      onPressed: widget.onPressed))
              : SizedBox(width: 150);
        });
  }
}
