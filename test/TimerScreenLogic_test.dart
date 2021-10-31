import 'package:cododoro/models/ElapsedTimeModel.dart';
import 'package:cododoro/models/TimerModel.dart';
import 'package:cododoro/models/TimerStates.dart';
import 'package:cododoro/storage/HistoryRepository.dart';
import 'package:cododoro/storage/Settings.dart';
import 'package:cododoro/viewlogic/TimerScreenLogic.dart' as TimerScreenLogic;
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'TimerScreenLogic_test.mocks.dart';

@GenerateMocks([ElapsedTimeModel, TimerModel, HistoryRepository, Settings])
void main() {
  test('Tick when timer is not running does not increase the elapsed time', () {
    ElapsedTimeModel mockElapsedTimeModel = MockElapsedTimeModel();
    TimerModel mockTimerModel = MockTimerModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();
    Settings mockSettings = MockSettings();

    when(mockTimerModel.isRunning()).thenReturn(false);
    when(mockTimerModel.isWorking).thenReturn(false);

    TimerScreenLogic.tick(
        mockElapsedTimeModel, mockTimerModel, mockHistoryRepo, mockSettings);

    verify(mockElapsedTimeModel.onTick(addTime: false));
  });

  test('Tick when timer is running does increase the elapsed time', () {
    ElapsedTimeModel mockElapsedTimeModel = MockElapsedTimeModel();
    TimerModel mockTimerModel = MockTimerModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();
    Settings mockSettings = MockSettings();

    when(mockTimerModel.isRunning()).thenReturn(true);
    when(mockTimerModel.isWorking).thenReturn(true);
    when(mockSettings.standingDesk).thenAnswer((_) => Future.value(true));
    when(mockSettings.targetStandingMinutes).thenAnswer((_) => Future.value(100));
    when(mockHistoryRepo.getTodayIntervals()).thenAnswer((_) => Future.value([]));
    when(mockTimerModel.state).thenReturn(TimerStates.noSession);
    when(mockElapsedTimeModel.elapsedTime).thenReturn(0);

    try {
      TimerScreenLogic.tick(
          mockElapsedTimeModel, mockTimerModel, mockHistoryRepo, mockSettings);
    } catch (e) {}

    verify(mockElapsedTimeModel.onTick(addTime: true));
  });
}
