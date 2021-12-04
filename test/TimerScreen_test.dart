import 'package:cododoro/models/ElapsedTimeModel.dart';
import 'package:cododoro/models/TimerStates.dart';
import 'package:cododoro/widgets/TimerScreen.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:cododoro/models/TimerModel.dart';
import 'package:cododoro/storage/HistoryRepository.dart';

import 'dart:convert';

class MockSharedPrefs extends Mock implements SharedPreferences {}

class MockTimerStateModel extends Mock implements TimerStateModel {}

class MockElapsedTimeModel extends Mock implements ElapsedTimeModel {}

void main() {
  test(
      'Stand dialog confirm function starts both stansing and working intervals',
      () async {
    ElapsedTimeModel mockElapsedTimeModel = MockElapsedTimeModel();
    TimerStateModel mockTimerModel = MockTimerStateModel();
    SharedPreferences mockPrefs = MockSharedPrefs();
    HistoryRepository historyRepo = HistoryRepository(prefs: mockPrefs);

    TimerScreen timerScreen = TimerScreen(key: ValueKey(""));

    when(() => mockPrefs.getStringList(any())).thenReturn([]);
    when(() => mockPrefs.setStringList(any(), any())).thenAnswer((_) => Future.value(true));
    when(() => mockTimerModel.state).thenReturn(TimerStates.noSession);

    timerScreen.createState().onPleaseStandUpConfirmed(
        mockElapsedTimeModel, mockTimerModel, historyRepo)();

    List lastWrite = verify(() => mockPrefs.setStringList(any(), captureAny())).captured.last;

    expect(
          StoredInterval.fromJson(json.decode(lastWrite[0])).type, IntervalType.stand);
    expect(
          StoredInterval.fromJson(json.decode(lastWrite[1])).type, IntervalType.work);
    expect(lastWrite.length, 2);
  });
}
