import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum IntervalType { work, rest }

void saveSession(DateTime endTime, IntervalType type, Duration duration) async {
  final newIntervalJson = PomodoroInterval(endTime, type, duration).toJson();

  final prefs = await SharedPreferences.getInstance();

  var todayIntervals = prefs.getStringList(key(endTime)) ?? [];

  todayIntervals.add(json.encode(newIntervalJson));

  prefs.setStringList(key(endTime), todayIntervals);

  print("${key(endTime)}: $todayIntervals");
}

Future<Iterable<PomodoroInterval>> getTodayIntervals() async {
  final prefs = await SharedPreferences.getInstance();

  var todayIntervals = prefs.getStringList(key(DateTime.now())) ?? [];

  return todayIntervals.map((e) => PomodoroInterval.fromJson(json.decode(e)));
}

void clearOldHistory() async {
  final prefs = await SharedPreferences.getInstance();

  prefs.getKeys().forEach((prefKey) {
    if (prefKey != key(DateTime.now()) && 
        prefKey != key(DateTime.now().subtract(Duration(days:1)))) {
      prefs.remove(prefKey);
    }
  });
}

String key(DateTime time) {
  return "${time.day}-${time.month}-${time.year}";
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
}
