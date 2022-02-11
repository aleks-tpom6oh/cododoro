import 'package:cododoro/storage/Settings.dart';
import 'package:cododoro/viewlogic/isDayChangeOnTick.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('tick at the same hour does not change', () async {
    // Given
    SharedPreferences.setMockInitialValues({dayHoursOffsetKey: 0});
    final lastTickTime = DateTime.parse('2012-02-21T14:00:00Z');
    final nextTickTime = DateTime.parse('2012-02-21T14:59:00Z');
    SharedPreferences.setMockInitialValues({});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final sut = IsDayChangeOnTick();

    // When
    sut.lastTickTime = lastTickTime;
    final result = sut.isDayChangeOnTick(nextTickTime, prefs);

    // Then
    expect(result, false);
  });

  test('tick at different hours in the same day does not change', () async {
    // Given
    SharedPreferences.setMockInitialValues({dayHoursOffsetKey: 0});
    final lastTickTime = DateTime.parse('2012-02-21T14:00:00Z');
    final nextTickTime = DateTime.parse('2012-02-21T19:59:00Z');
    SharedPreferences.setMockInitialValues({});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final sut = IsDayChangeOnTick();

    // When
    sut.lastTickTime = lastTickTime;
    final result = sut.isDayChangeOnTick(nextTickTime, prefs);

    // Then
    expect(result, false);
  });

  test('tick at in the different days does change', () async {
    // Given
    final lastTickTime = DateTime.parse('2012-02-21T23:59:00Z');
    final nextTickTime = DateTime.parse('2012-02-22T00:00:00Z');
    SharedPreferences.setMockInitialValues({dayHoursOffsetKey: 0});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final sut = IsDayChangeOnTick();

    // When
    sut.lastTickTime = lastTickTime;
    final result = sut.isDayChangeOnTick(nextTickTime, prefs);

    // Then
    expect(result, true);
  });

  test('plus hour adjustment makes the day change at 1 am', () async {
    // Given
    final lastTickTime = DateTime.parse('2012-02-21T00:59:00Z');
    final nextTickTime = DateTime.parse('2012-02-21T01:00:00Z');
    SharedPreferences.setMockInitialValues({dayHoursOffsetKey: 1});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final sut = IsDayChangeOnTick();

    // When
    sut.lastTickTime = lastTickTime;
    final result = sut.isDayChangeOnTick(nextTickTime, prefs);

    // Then
    expect(result, true);
  });

  test('minus hour adjustment makes the day change at 11 pm', () async {
    // Given
    final lastTickTime = DateTime.parse('2012-02-21T22:59:00Z');
    final nextTickTime = DateTime.parse('2012-02-21T23:00:00Z');
    SharedPreferences.setMockInitialValues({dayHoursOffsetKey: -1});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final sut = IsDayChangeOnTick();

    // When
    sut.lastTickTime = lastTickTime;
    final result = sut.isDayChangeOnTick(nextTickTime, prefs);

    // Then
    expect(result, true);
  });
}
