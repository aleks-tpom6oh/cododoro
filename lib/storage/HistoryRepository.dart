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

  Future<SharedPreferences> prefs;

  HistoryRepository({required this.prefs});

  Future<void> startSession(IntervalType type) async {
    final DateTime endTime = DateTime.now();
    final newInterval = StoredInterval(endTime, type, Duration(seconds: 0));
    if (type == IntervalType.stand) {
      _currentStandingSessionId = newInterval.id;
    } else {
      _previousPomodoroSessionId = _currentPomodoroSessionId;
      _currentPomodoroSessionId = newInterval.id;
    }
    await _saveSessionImpl(newInterval);
  }

  void stopStanding() {
    _currentStandingSessionId = null;
  }

  void saveSession(
      DateTime endTime, IntervalType type, Duration duration) async {
    final newInterval = StoredInterval(endTime, type, duration);
    await _saveSessionImpl(newInterval);
  }

  Future<void> _saveSessionImpl(Interval newInterval) async {
    final newIntervalJson = newInterval.toJson();

    final key =
        await dayKey(time: newInterval.endTime, maybePrefs: await prefs);

    var todayIntervals = (await prefs).getStringList(key) ?? [];

    todayIntervals.add(json.encode(newIntervalJson));

    await (await prefs).setStringList(key, todayIntervals);

    notifyListeners();
  }

  Future<void> updateCurrentStandingSession({bool addTime = true}) async {
    if (currentStandingSessionId != null) {
      final endTime = DateTime.now();
      var todayIntervals = (await prefs).getStringList(
              await dayKey(time: endTime, maybePrefs: await prefs)) ??
          [];

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
                  todayInterval.id, endTime, todayInterval.type, totalDuration)
              .toJson());
        } else {
          return json.encode(todayInterval.toJson());
        }
      }).toList();

      await (await prefs).setStringList(
          await dayKey(time: endTime, maybePrefs: await prefs), todayIntervals);

      notifyListeners();
    }
  }

  Future<void> updateCurrentPomodoroSession(
      DateTime endTime, Duration duration) async {
    await _updateCurrentSession(endTime, duration, _currentPomodoroSessionId);
  }

  Future<void> _updateCurrentSession(
      DateTime endTime, Duration duration, String? currentSessionId) async {
    var todayIntervals = (await prefs).getStringList(
            await dayKey(time: endTime, maybePrefs: await prefs)) ??
        [];

    todayIntervals = todayIntervals.map((todayIntervalString) {
      final todayInterval =
          StoredInterval.fromJson(json.decode(todayIntervalString));

      return json.encode((currentSessionId == todayInterval.id
              ? StoredInterval.withId(
                  todayInterval.id, endTime, todayInterval.type, duration)
              : todayInterval)
          .toJson());
    }).toList();

    final actualPrefs = await prefs;

    await actualPrefs.setStringList(
        await dayKey(time: endTime, maybePrefs: actualPrefs), todayIntervals);

    notifyListeners();
  }

  void toggleSessionType(Interval interval) async {
    final actualPrefs = await prefs;

    var todayIntervals = actualPrefs.getStringList(
            await dayKey(time: interval.endTime, maybePrefs: actualPrefs)) ??
        [];

    final StoredInterval targetInterval = StoredInterval.fromJson(json.decode(
        todayIntervals.firstWhere(
            (e) => StoredInterval.fromJson(json.decode(e)) == interval)));

    if (targetInterval.type == IntervalType.work ||
        targetInterval.type == IntervalType.rest) {
      final newTargetInterval = new StoredInterval.withId(
          targetInterval.id,
          targetInterval.endTime,
          targetInterval.type == IntervalType.work
              ? IntervalType.rest
              : IntervalType.work,
          targetInterval.duration);

      final targetIntervalJsonString = json.encode(targetInterval.toJson());

      final intervalIndex = todayIntervals.indexOf(targetIntervalJsonString);
      todayIntervals[intervalIndex] = json.encode(newTargetInterval.toJson());

      await actualPrefs.setStringList(
          await dayKey(time: interval.endTime, maybePrefs: actualPrefs),
          todayIntervals);

      notifyListeners();
    }
  }

  Future<bool> removeSession(Interval interval) async {
    final actualPrefs = await prefs;

    var todayIntervals = actualPrefs.getStringList(
            await dayKey(time: interval.endTime, maybePrefs: actualPrefs)) ??
        [];

    bool result = todayIntervals.remove(json.encode(interval.toJson()));

    actualPrefs.setStringList(
        await dayKey(time: interval.endTime, maybePrefs: actualPrefs),
        todayIntervals);

    notifyListeners();

    return result;
  }

  Future<Iterable<StoredInterval>> getTodayIntervals() async {
    var todayIntervals = (await prefs).getStringList(
            await dayKey(time: DateTime.now(), maybePrefs: await prefs)) ??
        [];

    return todayIntervals.map((e) => StoredInterval.fromJson(json.decode(e)));
  }
}

abstract class Interval {
  Map<String, dynamic> toJson();

  DateTime get endTime;
}

class StoredInterval extends Interval {
  final String id;
  final DateTime endTime;
  final IntervalType type;
  final Duration duration;

  StoredInterval(endTime, type, duration)
      : this.withId(UniqueKey().toString(), endTime, type, duration);

  StoredInterval.withId(this.id, this.endTime, this.type, this.duration);

  StoredInterval.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "no-id",
        endTime = DateTime.parse(json['endTime']),
        type =
            IntervalType.values.firstWhere((e) => e.toString() == json['type']),
        duration = json['durationMillis'] != null
            ? Duration(milliseconds: json['durationMillis'])
            : Duration(seconds: json['durationSeconds']);

  Map<String, dynamic> toJson() => {
        'id': id,
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
            type == other.type &&
            duration == other.duration;
  }

  @override
  int get hashCode =>
      id.hashCode ^ endTime.hashCode ^ type.hashCode ^ duration.hashCode;

  @override
  String toString() {
    return "${type.toString()} ${duration.toString()} ${endTime.toString()}";
  }
}
