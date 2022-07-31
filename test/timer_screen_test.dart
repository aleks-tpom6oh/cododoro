import 'package:cododoro/common/cubit/elapsed_time_cubit.dart';
import 'package:cododoro/common/data_layer/timer_states.dart';
import 'package:cododoro/notifications/base_notifier.dart';
import 'package:cododoro/home_screen/screen/timer_screen.dart';
import 'package:flutter/material.dart';
import 'package:mockito/annotations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:cododoro/common/data_layer/timer_state_model.dart';
import 'package:cododoro/common/data_layer/persistent/history_repository.dart';

import 'package:cododoro/home_screen/view_model/timer_screen_logic.dart' as logic;

import 'dart:convert';

import 'timer_screen_test.mocks.dart';

class MockSharedPrefs extends Mock implements SharedPreferences {}

class MockTimerStateModel extends Mock implements TimerStateModel {}

class MockElapsedTimeCubit extends Mock implements ElapsedTimeCubit {}

@GenerateMocks([BaseNotifier])
void main() {
  test(
      'Stand dialog confirm function starts both standing and working intervals',
      () async {
    ElapsedTimeCubit mockElapsedTimeCubit = MockElapsedTimeCubit();
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
        mockElapsedTimeCubit, mockTimerModel, historyRepo)();

    List lastWrite = verify(() => mockPrefs.setStringList(any(), captureAny())).captured.last;

    Iterable<StoredInterval> decodedLastWrite = lastWrite.map((e) { return StoredInterval.fromJson(json.decode(e)); });

    expect(true, decodedLastWrite.any((element) => element.type == IntervalType.stand));
    expect(true, decodedLastWrite.any((element) => element.type == IntervalType.work));
    expect(lastWrite.length, 2);
  });
}
