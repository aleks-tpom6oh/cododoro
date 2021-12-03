import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';

class RestIdeasDialog extends StatefulWidget {
  RestIdeasDialog({Key? key}) : super(key: key);

  @override
  _RestIdeasDialogState createState() => _RestIdeasDialogState();
}

class _RestIdeasDialogState extends State<RestIdeasDialog> {
  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Color(0xFFFF71DF)
        : Color(0xFF587FA8);

    return AlertDialog(
      title: Text("Healthy activities"),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("🏋️ ", style: TextStyle(color: textColor)),
                  InkWell(
                    onTap: () {
                      mixpanelTrack(eventName: "Workout Clicked", params: {});
                      launch('https://www.youtube.com/watch?v=mmq5zZfmIws');
                    },
                    child: Text("Workout",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: textColor)),
                  ),
                  Text(" 7 mins")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("🌬 ", style: TextStyle(color: textColor)),
                  InkWell(
                    onTap: () {
                      mixpanelTrack(
                          eventName: "Breath Exercise Clicked", params: {});
                      launch('https://xhalr.com/');
                    },
                    child: Text("Breath",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: textColor)),
                  ),
                  Text(" any duration")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("👀 ", style: TextStyle(color: textColor)),
                  InkWell(
                    onTap: () {
                      mixpanelTrack(
                          eventName: "Eyes Exersize Clicked", params: {});
                      launch('https://blimb.su/');
                    },
                    child: Text("Eyes exercise",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: textColor)),
                  ),
                  Text(" 3.5 mins")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("🧘 ", style: TextStyle(color: textColor)),
                  InkWell(
                    onTap: () {
                      mixpanelTrack(
                          eventName: "Meditation Clicked", params: {});
                      launch('https://meditationtimer.online/');
                    },
                    child: Text("Meditate",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: textColor)),
                  ),
                  Text(" any duration")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("🤸 ", style: TextStyle(color: textColor)),
                  InkWell(
                    onTap: () {
                      mixpanelTrack(
                          eventName: "Stretching Exercise Clicked",
                          params: {});
                      launch(
                          'https://www.spotebi.com/wp-content/uploads/2021/02/5-minute-full-body-cool-down-stretches-spotebi.gif');
                    },
                    child: Text("Stretching",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: textColor)),
                  ),
                  Text(" 3-6 mins")
                ],
              ),
            ),
          ]),
    );
  }
}
