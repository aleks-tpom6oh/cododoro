import 'package:cododoro/storage/HistoryRepository.dart';
import 'package:cododoro/storage/Settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddTimeDialog extends StatefulWidget {
  const AddTimeDialog({Key? key}) : super(key: key);

  @override
  _AddTimeDialogState createState() => _AddTimeDialogState();
}

class _AddTimeDialogState extends State<AddTimeDialog> {
  IntervalType currentIntervalType = IntervalType.work;

  TextEditingController newWorkDurationInputController =
      TextEditingController(text: "0");

  @override
  Widget build(BuildContext context) {
    final history = context.read<HistoryRepository>();
    final settings = context.read<Settings>();

    final standingDesk = settings.standingDesk;

    final List<IntervalType> intervalTypes = standingDesk
        ? IntervalType.values
        : IntervalType.values.sublist(0, IntervalType.values.length - 1);

    return AlertDialog(
      title: Text("Add Manually"),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              DropdownButton<String>(
                value: currentIntervalType.toString().split('.').last,
                items: intervalTypes
                    .map((intervalType) =>
                        intervalType.toString().split('.').last)
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
                onChanged: (newIntervalTypeString) {
                  if (newIntervalTypeString != null) {
                    final newIntervalType = IntervalType.values.firstWhere(
                        (element) =>
                            element.toString().contains(newIntervalTypeString));

                    setState(() {
                      currentIntervalType = newIntervalType;
                    });
                  }
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: newWorkDurationInputController,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  enabled: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              Text("minutes"),
              IconButton(
                onPressed: () {
                  final restVal = newWorkDurationInputController.text;
                  final newDuration =
                      Duration(minutes: (double.parse(restVal)).toInt());
                  final endTime = DateTime.now();
                  final startTime = endTime.subtract(newDuration);

                  history.saveSession(
                      startTime, endTime, currentIntervalType, newDuration);
                },
                icon: const Icon(Icons.add),
              )
            ],
          ),
        ],
      ),
    );
  }
}
