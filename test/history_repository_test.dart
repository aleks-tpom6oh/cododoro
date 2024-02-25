import 'dart:convert';

import 'package:cododoro/common/data_layer/persistent/history_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:clock/clock.dart';

void main() {
  DateTime targetDay = DateTime.parse('2012-02-21T14:59:00Z');
  Interval todayInterval = StoredInterval(
    startTime: DateTime.parse('2012-02-21T14:00:00Z'),
    endTime: targetDay,
    type: IntervalType.stand,
    duration: Duration(minutes: 59),
  );
  Interval yesterdayInterval = StoredInterval(
    startTime: DateTime.parse('2012-02-20T14:00:00Z'),
    endTime: DateTime.parse('2012-02-20T14:59:00Z'),
    type: IntervalType.stand,
    duration: Duration(minutes: 59),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    SharedPreferences.setMockInitialValues({
      dayKeyCache(time: todayInterval.endTime, prefs: prefs): [
        json.encode(todayInterval.toJson())
      ],
      dayKeyCache(time: yesterdayInterval.endTime, prefs: prefs): [
        json.encode(yesterdayInterval.toJson())
      ]
    });
  });

  test('getWeekIntervals', () async {
    // Given
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final sut = HistoryRepository(prefs: prefs);
    
    // When
    final intervals = withClock(Clock.fixed(targetDay), () {
      return sut.getWeekIntervals(weekStartDay: 1);
    });

    // Then
    expect(intervals, [todayInterval, yesterdayInterval]);
  });
}
