import 'package:cododoro/models/ElapsedTimeModel.dart';
import 'package:cododoro/models/TimerStates.dart';
import 'package:cododoro/notifiers/BaseNotifier.dart';
import 'package:cododoro/widgets/TimerScreen.dart';
import 'package:flutter/material.dart';
import 'package:mockito/annotations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:cododoro/models/TimerStateModel.dart';
import 'package:cododoro/storage/HistoryRepository.dart';

import 'package:cododoro/viewlogic/TimerScreenLogic.dart' as logic;

import 'dart:convert';

import 'TimerScreen_test.mocks.dart';

class MockSharedPrefs extends Mock implements SharedPreferences {}

class MockTimerStateModel extends Mock implements TimerStateModel {}

class MockElapsedTimeModel extends Mock implements ElapsedTimeModel {}

@GenerateMocks([BaseNotifier])
void main() {
  test(
      'Stand dialog confirm function starts both stansing and working intervals',
      () async {
    ElapsedTimeModel mockElapsedTimeModel = MockElapsedTimeModel();
    TimerStateModel mockTimerModel = MockTimerStateModel();
    SharedPreferences mockPrefs = MockSharedPrefs();
    HistoryRepository historyRepo = HistoryRepository(prefs: mockPrefs);

    // ignore: no-empty-block
    TimerScreen timerScreen = TimerScreen(key: ValueKey(""), showIdleScreen: () {});

    when(() => mockPrefs.getStringList(any())).thenReturn([]);
    when(() => mockPrefs.setStringList(any(), any())).thenAnswer((_) => Future.value(true));
    when(() => mockTimerModel.state).thenReturn(TimerStates.noSession);

    final state = timerScreen.createState();

    logic.soundNotifier = MockBaseNotifier();
    logic.notifiers = [];

    state.onPleaseStandUpConfirmed(
        mockElapsedTimeModel, mockTimerModel, historyRepo)();

    List lastWrite = verify(() => mockPrefs.setStringList(any(), captureAny())).captured.last;

    Iterable<StoredInterval> decodedLastWrite = lastWrite.map((e) { return StoredInterval.fromJson(json.decode(e)); });

    expect(true, decodedLastWrite.any((element) => element.type == IntervalType.stand));
    expect(true, decodedLastWrite.any((element) => element.type == IntervalType.work));
    expect(lastWrite.length, 2);
  });
}
