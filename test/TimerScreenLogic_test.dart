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

@GenerateMocks([ElapsedTimeModel, TimerStateModel, HistoryRepository, Settings])
void main() {
  test('Tick when timer is not running does not increase the elapsed time', () {
    ElapsedTimeModel mockElapsedTimeModel = MockElapsedTimeModel();
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();
    Settings mockSettings = MockSettings();

    when(mockTimerModel.isRunning()).thenReturn(false);
    when(mockTimerModel.isWorking).thenReturn(false);

    TimerScreenLogic.tick(
        // ignore: no-empty-block
        mockElapsedTimeModel,
        mockTimerModel,
        mockHistoryRepo,
        mockSettings,
        isStanding: false,
        // ignore: no-empty-block
        onReachedStandingGoal: () {});

    verify(mockElapsedTimeModel.onTick(addTime: false));
  });

  test('Tick when timer is running does increase the elapsed time', () {
    ElapsedTimeModel mockElapsedTimeModel = MockElapsedTimeModel();
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();
    Settings mockSettings = MockSettings();

    when(mockTimerModel.isRunning()).thenReturn(true);
    when(mockTimerModel.isWorking).thenReturn(true);
    when(mockSettings.standingDesk).thenAnswer((_) => true);
    when(mockSettings.targetStandingMinutes)
        .thenAnswer((_) => 100);
    when(mockHistoryRepo.getTodayIntervals())
        .thenAnswer((_) => []);
    when(mockTimerModel.state).thenReturn(TimerStates.noSession);
    when(mockElapsedTimeModel.elapsedTime).thenReturn(0);

    try {
      TimerScreenLogic.tick(
          // ignore: no-empty-block
          mockElapsedTimeModel,
          mockTimerModel,
          mockHistoryRepo,
          mockSettings,
          isStanding: false,
          // ignore: no-empty-block
          onReachedStandingGoal: () {});
    } catch (e) {}

    verify(mockElapsedTimeModel.onTick(addTime: true));
  });

  test('Start session does nothing if session is there', () {
    ElapsedTimeModel mockElapsedTimeModel = MockElapsedTimeModel();
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    TimerStates.values.forEach((timerState) {
      if (timerState == TimerStates.noSession) {
        return;
      }

      when(mockTimerModel.state).thenReturn(timerState);

      TimerScreenLogic.startSession(
          mockElapsedTimeModel, mockTimerModel, mockHistoryRepo);

      verifyNever(mockTimerModel.forceResume());
      verifyNever(mockTimerModel.state = TimerStates.sessionWorking);
      verifyZeroInteractions(mockElapsedTimeModel);
      verifyZeroInteractions(mockHistoryRepo);
    });
  });

  test(
      'Start session resumes and starts a working session if no session currently',
      () {
    ElapsedTimeModel mockElapsedTimeModel = MockElapsedTimeModel();
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    when(mockTimerModel.state).thenReturn(TimerStates.noSession);

    TimerScreenLogic.startSession(
        mockElapsedTimeModel, mockTimerModel, mockHistoryRepo);

    verify(mockTimerModel.forceResume());
    verify(mockTimerModel.state = TimerStates.sessionWorking);
    verify(mockElapsedTimeModel.elapsedTime = 0);
    verify(mockHistoryRepo.startSession(IntervalType.work));
  });

  test(
      'Start session resumes and starts a working session if no session currently and paused',
      () {
    ElapsedTimeModel mockElapsedTimeModel = MockElapsedTimeModel();
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    when(mockTimerModel.state).thenReturn(TimerStates.noSession);
    when(mockTimerModel.isPaused).thenReturn(true);

    TimerScreenLogic.startSession(
        mockElapsedTimeModel, mockTimerModel, mockHistoryRepo);

    verify(mockTimerModel.forceResume());
    verify(mockTimerModel.state = TimerStates.sessionWorking);
    verify(mockElapsedTimeModel.elapsedTime = 0);
    verify(mockHistoryRepo.startSession(IntervalType.work));
  });

  test(
      'Should ask if you are still standing if started standing while working',
      () {
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    when(mockTimerModel.state).thenReturn(TimerStates.sessionWorking);

    TimerScreenLogic.startStanding(mockHistoryRepo, mockTimerModel);

    when(mockTimerModel.state).thenReturn(TimerStates.sessionResting);

    expect(TimerScreenLogic.shouldAskStillStanding(true, mockTimerModel), true);
  });

  test(
      'Should ask if you are still standing if started standing while working',
      () {
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    when(mockTimerModel.state).thenReturn(TimerStates.sessionWorking);

    TimerScreenLogic.startStanding(mockHistoryRepo, mockTimerModel);

    when(mockTimerModel.state).thenReturn(TimerStates.sessionResting);

    expect(TimerScreenLogic.shouldAskStillStanding(true, mockTimerModel), true);
  });

  test(
      'Should ask if you are still standing if started standing while working overtime',
      () {
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    when(mockTimerModel.state).thenReturn(TimerStates.sessionWorkingOvertime);

    TimerScreenLogic.startStanding(mockHistoryRepo, mockTimerModel);

    when(mockTimerModel.state).thenReturn(TimerStates.sessionResting);

    expect(TimerScreenLogic.shouldAskStillStanding(true, mockTimerModel), true);
  });

  test(
      'Should not ask if you are still standing if started standing during resting',
      () {
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    when(mockTimerModel.state).thenReturn(TimerStates.sessionResting);

    TimerScreenLogic.startStanding(mockHistoryRepo, mockTimerModel);

    expect(TimerScreenLogic.shouldAskStillStanding(true, mockTimerModel), false);
  });

  test(
      'Should not ask if you are still standing if started standing during resting overtime',
      () {
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    when(mockTimerModel.state).thenReturn(TimerStates.sessionRestingOvertime);

    TimerScreenLogic.startStanding(mockHistoryRepo, mockTimerModel);

    expect(TimerScreenLogic.shouldAskStillStanding(true, mockTimerModel), false);
  });

    test(
      'Should not ask if you are still standing when not standing',
      () {
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    when(mockTimerModel.state).thenReturn(TimerStates.sessionWorkingOvertime);

    TimerScreenLogic.startStanding(mockHistoryRepo, mockTimerModel);

    when(mockTimerModel.state).thenReturn(TimerStates.sessionRestingOvertime);

    expect(TimerScreenLogic.shouldAskStillStanding(false, mockTimerModel), false);
  });
}