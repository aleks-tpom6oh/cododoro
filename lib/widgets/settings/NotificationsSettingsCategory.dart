import 'package:flutter/material.dart';
import 'package:cododoro/data_layer/storage/NotificationsSchedule.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class NotificationsSettingsCategory extends StatelessWidget {
  const NotificationsSettingsCategory({
    Key? key,
    required this.startNotificationDelayTimeInputController,
  }) : super(key: key);

  final TextEditingController startNotificationDelayTimeInputController;

  @override
  Widget build(BuildContext context) {
    var notificationSchedule = context.watch<NotificationSchedule>();
    
    return FutureBuilder<Strategy>(
        future: notificationSchedule.strategy,
        builder:
            (BuildContext context, AsyncSnapshot<Strategy> strategySnapshot) {
          final currentStrutegyString =
              strategySnapshot.data?.toString().split('.').last;
          
          return FutureBuilder<int>(
              future: notificationSchedule.baseTime,
              builder: (context, baseTimeSnapshot) {
                startNotificationDelayTimeInputController.text =
                    baseTimeSnapshot.hasData
                        ? baseTimeSnapshot.data.toString()
                        : "?";
                
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: Text(
                        "Notifications",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      //width: 240,
                      child: Text(
                          "When a session goes overtime the app will start sending periodic notifications with decreasing delay unitil once a minute.",
                          textAlign: TextAlign.center),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Decrease as"),
                        DropdownButton<String>(
                          value: currentStrutegyString,
                          items: Strategy.values
                              .map(
                                  (strategy) => strategy.toString().split('.').last)
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          onChanged: (newStrategyString) {
                            if (newStrategyString != null) {
                              final newStrategy = Strategy.values.firstWhere(
                                  (element) => element
                                      .toString()
                                      .contains(newStrategyString));
                              notificationSchedule.setStrategy(newStrategy);
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller:
                                startNotificationDelayTimeInputController,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            enabled: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                                alignLabelWithHint: true,
                                labelText: "Start notification delay in minutes",
                                hintText: "1"),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            final restVal =
                                startNotificationDelayTimeInputController.text;
                            final newBaseTime = int.parse(restVal);

                            if (strategySnapshot.data == Strategy.Fibonacci &&
                                !fibonaccis.contains(newBaseTime)) {
                              final snackBar = SnackBar(
                                  content: Text(
                                      'Use a Fibonacci value up to ${fibonaccis.last}'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            } else {
                              notificationSchedule.setBaseTime(newBaseTime);
                            }
                          },
                          child: const Text('Set'),
                        )
                      ],
                    ),
                    FutureBuilder<Object>(
                        future: notificationSchedule.computeTimes(),
                        builder: (context, snapshot) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: Text(
                              "Notification delays: " +
                                  (snapshot.hasData
                                      ? "${snapshot.data.toString()}"
                                      : ""),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                  ],
                );
              });
        });
  }
}
