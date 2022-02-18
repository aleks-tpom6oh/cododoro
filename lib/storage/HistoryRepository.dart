import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Settings.dart' as Settings;

enum IntervalType { work, rest, stand }

String? _previousPomodoroSessionId;
String? _currentPomodoroSessionId;
String? _currentStandingSessionId;

String? get previousPomodoroSessionId => _previousPomodoroSessionId;
String? get currentPomodoroSessionId => _currentPomodoroSessionId;
String? get currentStandingSessionId => _currentStandingSessionId;

Future<String> dayKey(
    {required DateTime time, SharedPreferences? maybePrefs}) async {
  final prefs = maybePrefs ?? await SharedPreferences.getInstance();
  final hoursOffset = Settings.getDayHoursOffset(prefs);

  final newTime = time.subtract(Duration(hours: hoursOffset));

  return "${newTime.day}-${newTime.month}-${newTime.year}";
}

String dayKeyCache({required DateTime time, required SharedPreferences prefs}) {
  final hoursOffset = Settings.getDayHoursOffset(prefs);

  final newTime = time.subtract(Duration(hours: hoursOffset));

  return "${newTime.day}-${newTime.month}-${newTime.year}";
}

void clearOldHistory() async {
  RegExp dayKeyRegExp = new RegExp(
    r"/\d{1-2}-\d{1-2}-\d{4}/",
    caseSensitive: false,
    multiLine: false,
  );

  final keepKeys = [
    await dayKey(time: DateTime.now()),
    await dayKey(time: DateTime.now().subtract(Duration(days: 1))),
  ];

  final prefs = await SharedPreferences.getInstance();
  prefs.getKeys().forEach((prefKey) async {
    if (!keepKeys.contains(prefKey) && dayKeyRegExp.hasMatch(prefKey)) {
      prefs.remove(prefKey);
    }
  });
}

class HistoryRepository with ChangeNotifier {
  SharedPreferences prefs;

  HistoryRepository({required this.prefs});

  void startSession(IntervalType type) {
    final newInterval = StoredInterval(
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        type: type,
        duration: Duration(seconds: 0));
    if (type == IntervalType.stand) {
      _currentStandingSessionId = newInterval.id;
    } else {
      _previousPomodoroSessionId = _currentPomodoroSessionId;
      _currentPomodoroSessionId = newInterval.id;
    }
    _saveSessionImpl(newInterval);
  }

  void stopStanding() {
    _currentStandingSessionId = null;
  }

  void saveSession(DateTime startTime, DateTime endTime, IntervalType type,
      Duration duration) {
    final newInterval = StoredInterval(
        startTime: startTime, endTime: endTime, type: type, duration: duration);
    _saveSessionImpl(newInterval);
  }

  void _saveSessionImpl(Interval newInterval) {
    final newIntervalJson = newInterval.toJson();

    final key = dayKeyCache(time: newInterval.endTime, prefs: prefs);

    var todayIntervals = prefs.getStringList(key) ?? [];

    todayIntervals.add(json.encode(newIntervalJson));

    prefs.setStringList(key, todayIntervals);

    notifyListeners();
  }

  void updateCurrentStandingSession({bool addTime = true}) {
    if (currentStandingSessionId != null) {
      final endTime = DateTime.now();
      var todayIntervals =
          prefs.getStringList(dayKeyCache(time: endTime, prefs: prefs)) ?? [];

      todayIntervals = todayIntervals.map((todayIntervalString) {
        final todayInterval =
            StoredInterval.fromJson(json.decode(todayIntervalString));
        if (_currentStandingSessionId == todayInterval.id) {
          final additionalDuration = addTime
              ? DateTime.now().difference(todayInterval.endTime)
              : new Duration(milliseconds: 0);
          final totalDuration = new Duration(
              microseconds: todayInterval.duration.inMicroseconds +
                  additionalDuration.inMicroseconds);

          return json.encode(StoredInterval.withId(
                  todayInterval.id,
                  todayInterval.startTime,
                  endTime,
                  todayInterval.type,
                  totalDuration)
              .toJson());
        } else {
          return json.encode(todayInterval.toJson());
        }
      }).toList();

      prefs.setStringList(
          dayKeyCache(time: endTime, prefs: prefs), todayIntervals);

      notifyListeners();
    }
  }

  void updateCurrentPomodoroSession(DateTime endTime, Duration duration) {
    _updateCurrentSession(endTime, duration, _currentPomodoroSessionId);
  }

  void _updateCurrentSession(
      DateTime endTime, Duration duration, String? currentSessionId) {
    var todayIntervals =
        prefs.getStringList(dayKeyCache(time: endTime, prefs: prefs)) ?? [];

    todayIntervals = todayIntervals.map((todayIntervalString) {
      final todayInterval =
          StoredInterval.fromJson(json.decode(todayIntervalString));

      return json.encode((currentSessionId == todayInterval.id
              ? StoredInterval.withId(todayInterval.id, todayInterval.startTime,
                  endTime, todayInterval.type, duration)
              : todayInterval)
          .toJson());
    }).toList();

    prefs.setStringList(
        dayKeyCache(time: endTime, prefs: prefs), todayIntervals);

    notifyListeners();
  }

  void toggleSessionType(Interval interval) {
    var todayIntervals = prefs
            .getStringList(dayKeyCache(time: interval.endTime, prefs: prefs)) ??
        [];

    final StoredInterval targetInterval = StoredInterval.fromJson(json.decode(
        todayIntervals.firstWhere(
            (e) => StoredInterval.fromJson(json.decode(e)) == interval)));

    if (targetInterval.type == IntervalType.work ||
        targetInterval.type == IntervalType.rest) {
      final newTargetInterval = new StoredInterval.withId(
          targetInterval.id,
          targetInterval.startTime,
          targetInterval.endTime,
          targetInterval.type == IntervalType.work
              ? IntervalType.rest
              : IntervalType.work,
          targetInterval.duration);

      final targetIntervalJsonString = json.encode(targetInterval.toJson());

      final intervalIndex = todayIntervals.indexOf(targetIntervalJsonString);
      todayIntervals[intervalIndex] = json.encode(newTargetInterval.toJson());

      prefs.setStringList(
          dayKeyCache(time: interval.endTime, prefs: prefs), todayIntervals);

      notifyListeners();
    }
  }

  bool removeSession(Interval interval) {
    var todayIntervals = prefs
            .getStringList(dayKeyCache(time: interval.endTime, prefs: prefs)) ??
        [];

    bool result = todayIntervals.remove(json.encode(interval.toJson()));

    prefs.setStringList(
        dayKeyCache(time: interval.endTime, prefs: prefs), todayIntervals);

    notifyListeners();

    return result;
  }

  Iterable<StoredInterval> getTodayIntervals() {
    var todayIntervals =
        prefs.getStringList(dayKeyCache(time: DateTime.now(), prefs: prefs)) ??
            [];

    return todayIntervals.map((e) => StoredInterval.fromJson(json.decode(e)));
  }

  StoredInterval? getLatestPomodoroInterval() {
    final pomodoroIntervals = getTodayIntervals().where((element) =>
        element.type == IntervalType.work || element.type == IntervalType.rest);

    if (pomodoroIntervals.isEmpty) {
      return null;
    } else {
      return pomodoroIntervals.reduce((value, element) {
        return element.endTime.isAfter(value.endTime) ? element : value;
      });
    }
  }
}

abstract class Interval {
  Map<String, dynamic> toJson();

  DateTime get endTime;
  DateTime get startTime;
}

class StoredInterval extends Interval {
  final String id;
  final DateTime endTime;
  late final DateTime startTime;
  final IntervalType type;
  final Duration duration;

  StoredInterval({startTime, endTime, type, duration})
      : this.withId(UniqueKey().toString(), startTime, endTime, type, duration);

  StoredInterval.withId(
      this.id, this.startTime, this.endTime, this.type, this.duration);

  StoredInterval.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "no-id",
        endTime = DateTime.parse(json['endTime']),
        type =
            IntervalType.values.firstWhere((e) => e.toString() == json['type']),
        duration = json['durationMillis'] != null
            ? Duration(milliseconds: json['durationMillis'])
            : Duration(seconds: json['durationSeconds']) {
    this.startTime = json['startTime'] != null
        ? DateTime.parse(json['startTime'])
        : this.endTime.subtract(this.duration);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'type': type.toString(),
        'durationMillis': duration.inMilliseconds
      };

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StoredInterval && id != "no-id" && id == other.id ||
        other is StoredInterval &&
            runtimeType == other.runtimeType &&
            endTime == other.endTime &&
            startTime == other.startTime &&
            type == other.type &&
            duration == other.duration;
  }

  @override
  int get hashCode =>
      id.hashCode ^ startTime.hashCode ^ type.hashCode ^ duration.hashCode;

  @override
  String toString() {
    return "${type.toString()} ${duration.toString()} ${startTime.toString()}";
  }
}
