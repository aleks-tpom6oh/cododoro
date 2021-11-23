import 'package:cododoro/models/ElapsedTimeModel.dart';
import 'package:cododoro/storage/NotificationsSchedule.dart';
import 'package:cododoro/widgets/views/StatsListToggleButton.dart';
import 'package:flutter/material.dart';
import 'package:cododoro/storage/HistoryRepository.dart';
import 'package:cododoro/utils.dart';
import 'package:provider/provider.dart';
import 'package:cododoro/widgets/dialogs/AddTimeDialog.dart';

enum ListState { pomodoro, standing }

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  ListState currentListState = ListState.pomodoro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stats Screen"),
      ),
      body: Center(
          child: Selector<ElapsedTimeModel, int>(
        selector: (_, elapsedTimeModel) => elapsedTimeModel.elapsedTime,
        builder: (_, __, ___) {
          final historyRepository = context.read<HistoryRepository>();

          final todayIntervals = historyRepository.getTodayIntervals();

          return screenContents(todayIntervals, context, historyRepository);
        },
      )),
    );
  }

  Widget screenContents(Iterable<StoredInterval> todayIntervals,
      BuildContext context, HistoryRepository historyRepository) {
    final workDuration =
        calculateTimeForIntervalType(todayIntervals, IntervalType.work);
    final restDuration =
        calculateTimeForIntervalType(todayIntervals, IntervalType.rest);
    final standingDuration =
        calculateTimeForIntervalType(todayIntervals, IntervalType.stand);

    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: IconButton(
                onPressed: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return ChangeNotifierProvider(
                        create: (context) => NotificationSchedule(),
                        child: AddTimeDialog(),
                      );
                    },
                  );
                },
                icon: Icon(Icons.add)),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("💻 Worked for ${workDuration.toHmsString()}"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("🏖 Rested for ${restDuration.toHmsString()}"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("🧍 Stood for ${standingDuration.toMsString()}"),
            ),
            StatsListToggleButton(onToggle: (listState) {
              setState(() {
                currentListState = listState;
              });
            }),
            Expanded(
                child:
                    intervalsList(todayIntervals, context, historyRepository))
          ],
        )
      ],
    );
  }

  ListView intervalsList(Iterable<StoredInterval> todayIntervals,
      BuildContext context, HistoryRepository historyRepository) {
    return ListView(
        padding: const EdgeInsets.all(8),
        children: (todayIntervals
            .toList()
            .reversed
            .where((element) {
              return currentListState == ListState.pomodoro
                  ? element.type != IntervalType.stand
                  : element.type == IntervalType.stand;
            })
            .map(
              (interval) => Dismissible(
                key: UniqueKey(),
                background: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0xFF990000)
                      : Color(0xFFE72400),
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.cancel),
                ),
                confirmDismiss: (DismissDirection direction) async {
                  return onRowDismiss(direction, interval, historyRepository);
                },
                child: singleRowUi(interval, context, historyRepository),
              ),
            )
            .toList()));
  }

  Future<bool> onRowDismiss(DismissDirection direction, StoredInterval interval,
      HistoryRepository historyRepository) async {
    if (interval.id == currentPomodoroSessionId ||
        interval.id == currentStandingSessionId) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Can\'t delete current interval')));

      return false;
    }

    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you want to delete this interval?"),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  historyRepository.removeSession(interval);
                  Navigator.of(context).pop(true);
                },
                child: const Text("DELETE",
                    style: TextStyle(
                      color: Colors.black,
                    ))),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCEL",
                  style: TextStyle(
                    color: Colors.black,
                  )),
            ),
          ],
        );
      },
    );
  }

  Padding singleRowUi(StoredInterval interval, BuildContext context,
      HistoryRepository historyRepository) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          height: 50,
          color: interval.type == IntervalType.work ||
                  interval.type == IntervalType.stand
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColorLight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      'You did ${interval.type.toString().split('.').last} for ${interval.duration.toHmsString()}'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: interval.id == currentPomodoroSessionId ||
                          interval.type == IntervalType.stand
                      ? null
                      : () => historyRepository.toggleSessionType(interval),
                  child: interval.type == IntervalType.stand
                      ? SizedBox.shrink()
                      : Text(
                          'Toggle type',
                          style: interval.id == currentPomodoroSessionId ||
                                  interval.type == IntervalType.stand
                              ? TextStyle(
                                  color: Colors.grey,
                                )
                              : TextStyle(
                                  color: Colors.black,
                                ),
                        ),
                ),
              )
            ],
          )),
    );
  }
}
