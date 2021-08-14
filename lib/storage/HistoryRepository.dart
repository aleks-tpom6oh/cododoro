import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'BaseSharedPrefs.dart';

enum IntervalType { work, rest }

void saveSession(DateTime endTime, IntervalType type, Duration duration) async {
  final newIntervalJson = PomodoroInterval(endTime, type, duration).toJson();

  final prefs = await SharedPreferences.getInstance();

  var todayIntervals = prefs.getStringList(dayKey(endTime)) ?? [];

  todayIntervals.add(json.encode(newIntervalJson));

  prefs.setStringList(dayKey(endTime), todayIntervals);
}

String dayKey(DateTime time) {
  return "${time.day}-${time.month}-${time.year}";
}

void clearOldHistory() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.getKeys().forEach((prefKey) async {
    if (prefKey != dayKey(DateTime.now()) &&
        prefKey != dayKey(DateTime.now().subtract(Duration(days: 1)))) {
      prefs.remove(prefKey);
    }
  });
}

class HistoryRepository extends BaseSharedPrefs {
  void toggleSessionType(PomodoroInterval interval) async {
    var todayIntervals =
        (await prefs).getStringList(dayKey(interval.endTime)) ?? [];

    final PomodoroInterval targetInterval = PomodoroInterval.fromJson(
        json.decode(todayIntervals.firstWhere(
            (e) => PomodoroInterval.fromJson(json.decode(e)) == interval)));

    final newTargetInterval = new PomodoroInterval(
        targetInterval.endTime,
        targetInterval.type == IntervalType.work
            ? IntervalType.rest
            : IntervalType.work,
        targetInterval.duration);

    final targetIntervalJsonString = json.encode(targetInterval.toJson());

    final intervalIndex = todayIntervals.indexOf(targetIntervalJsonString);
    todayIntervals[intervalIndex] = json.encode(newTargetInterval.toJson());

    (await prefs).setStringList(dayKey(interval.endTime), todayIntervals);

    notifyListeners();
  }

  Future<Iterable<PomodoroInterval>> getTodayIntervals() async {
    var todayIntervals =
        (await prefs).getStringList(dayKey(DateTime.now())) ?? [];

    return todayIntervals.map((e) => PomodoroInterval.fromJson(json.decode(e)));
  }
}

class PomodoroInterval {
  final DateTime endTime;
  final IntervalType type;
  final Duration duration;

  PomodoroInterval(this.endTime, this.type, this.duration);

  PomodoroInterval.fromJson(Map<String, dynamic> json)
      : endTime = DateTime.parse(json['endTime']),
        type =
            IntervalType.values.firstWhere((e) => e.toString() == json['type']),
        duration = Duration(seconds: json['durationSeconds']);

  Map<String, dynamic> toJson() => {
        'endTime': endTime.toIso8601String(),
        'type': type.toString(),
        'durationSeconds': duration.inSeconds
      };

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PomodoroInterval &&
            runtimeType == other.runtimeType &&
            endTime == other.endTime &&
            type == other.type &&
            duration == other.duration;
  }

  @override
  int get hashCode => endTime.hashCode ^ type.hashCode ^ duration.hashCode;
}
