import 'package:cododoro/storage/Settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StandingDeskSettingsCategory extends StatefulWidget {
  const StandingDeskSettingsCategory({
    Key? key,
    required this.settings,
  }) : super(key: key);

  final Settings? settings;

  @override
  _StandingDeskSettingsCategoryState createState() =>
      _StandingDeskSettingsCategoryState();
}

class _StandingDeskSettingsCategoryState
    extends State<StandingDeskSettingsCategory> {
  bool? standingDeskEnabled;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.greenAccent;
      }
      
      return Colors.grey;
    }

    final textController = new TextEditingController();

    return FutureBuilder(
        future: this.widget.settings?.standingDesk,
        builder: (BuildContext context, AsyncSnapshot<bool> standSnapshot) {
          return FutureBuilder(
              future: this.widget.settings?.targetStandingMinutes,
              builder: (BuildContext context,
                  AsyncSnapshot<int> targetStandingMinutesSnapshot) {
                if (standSnapshot.hasData &&
                    targetStandingMinutesSnapshot.data != null) {
                  standingDeskEnabled = standSnapshot.data;
                  var targetStandingTime = targetStandingMinutesSnapshot.data;
                  textController.text = targetStandingTime.toString();
                  
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: Text(
                          "Health",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: standingDeskEnabled,
                            onChanged: (bool? value) {
                              if (value != null) {
                                widget.settings?.setStandingDesk(value);
                                setState(() {
                                  standingDeskEnabled = value;
                                });
                              }
                            },
                          ),
                          Text("Track standing desk usage"),
                        ],
                      ),
                      Row(
                        children: [
                      standingDeskEnabled == true ? Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: TextField(
                                controller: textController,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                enabled: true,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                    alignLabelWithHint: true,
                                    labelText: "Terget standing minutes per day"),
                              ),
                            ),
                          ) : SizedBox(),
                          standingDeskEnabled == true ? TextButton(
                            onPressed: () {
                              final newTaretStandingTime =
                                  int.tryParse(textController.text);
                              if (newTaretStandingTime != null &&
                                  newTaretStandingTime > 0 &&
                                  newTaretStandingTime <= 600) {
                                widget.settings?.setTargetStandingMinutes(
                                    newTaretStandingTime);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Use an integer from 1 to 600')));
                              }
                            },
                            child: const Text('Set'),
                          ) : SizedBox(height: 51,)
                        ]),
                    ],
                  );
                } else {
                  return const Text("Loading...");
                }
              });
        });
  }
}
