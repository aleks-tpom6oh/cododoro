import 'package:cododoro/common/cubit/elapsed_time_cubit.dart';
import 'package:cododoro/common/cubit/elapsed_time_state.dart';
import 'package:cododoro/common/data_layer/timer_state_model.dart';
import 'package:cododoro/common/data_layer/timer_states.dart';
import 'package:cododoro/common/data_layer/persistent/history_repository.dart';
import 'package:cododoro/common/data_layer/persistent/settings.dart';
import 'package:cododoro/notifications/base_notifier.dart';
import 'package:cododoro/onboarding/onboarding_config.dart';
import 'package:cododoro/common/utils/is_day_change_on_tick.dart';
import 'package:cododoro/home_screen/view_model/timer_screen_logic.dart'
    as TimerScreenLogic;
import 'package:flutter/material.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import 'timer_screen_logic_test.mocks.dart';

class AlwaysTrueIsDayChangeOnTick implements IsDayChangeOnTick {
  @override
  DateTime lastTickTime = DateTime.now();

  @override
  isDayChangeOnTick(DateTime newTickTime, SharedPreferences prefs) {
    return true;
  }
}

class AlwaysFalseIsDayChangeOnTick implements IsDayChangeOnTick {
  @override
  DateTime lastTickTime = DateTime.now();

  @override
  isDayChangeOnTick(DateTime newTickTime, SharedPreferences prefs) {
    return false;
  }
}

@GenerateMocks([
  ElapsedTimeCubit,
  TimerStateModel,
  HistoryRepository,
  Settings,
  BaseNotifier
])
void main() {
  test('Tick when timer is not running does not increase the elapsed time',
      () async {
    ElapsedTimeCubit mockElapsedTimeCubit = MockElapsedTimeCubit();
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();
    Settings mockSettings = MockSettings();
    SharedPreferences.setMockInitialValues({});
    SharedPreferences prefs = await SharedPreferences.getInstance();

    when(mockTimerModel.isRunning()).thenReturn(false);
    when(mockTimerModel.isWorking).thenReturn(false);

    TimerScreenLogic.tick(
        // ignore: no-empty-block
        mockElapsedTimeCubit,
        mockTimerModel,
        mockHistoryRepo,
        mockSettings,
        prefs,
        isStanding: false,
        isDayChangeOnTick: AlwaysFalseIsDayChangeOnTick(),
        // ignore: no-empty-block
        onReachedStandingGoal: () {});

    verify(mockElapsedTimeCubit.onTick(addTime: false));
  });

  test('Starts work session on init when onboarding step 1 is passed', () {
    WidgetsFlutterBinding.ensureInitialized();

    // Given
    SharedPreferences.setMockInitialValues({});

    ElapsedTimeCubit mockElapsedTimeCubit = MockElapsedTimeCubit();
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();
    OnboardingConfig config = OnboardingConfig();
    config.setStepShown(1);
    when(mockTimerModel.state).thenReturn(TimerStates.noSession);

    // When
    TimerScreenLogic.onOnboardingConfigLoaded(
        config, mockElapsedTimeCubit, mockTimerModel, mockHistoryRepo);

    // Then
    verify(mockHistoryRepo.startSession(IntervalType.work));
    verify(mockTimerModel.state = TimerStates.sessionWorking);
  });

  test(
      'Does not start work session on init when onboarding step 1 is not passed',
      () {
    WidgetsFlutterBinding.ensureInitialized();

    // Given
    SharedPreferences.setMockInitialValues({});

    ElapsedTimeCubit mockElapsedTimeCubit = MockElapsedTimeCubit();
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();
    OnboardingConfig config = OnboardingConfig();
    config.setStepShown(0);
    when(mockTimerModel.state).thenReturn(TimerStates.noSession);

    // When
    TimerScreenLogic.onOnboardingConfigLoaded(
        config, mockElapsedTimeCubit, mockTimerModel, mockHistoryRepo);

    // Then
    verifyNever(mockHistoryRepo.startSession(IntervalType.work));
    verifyNever(mockTimerModel.state = TimerStates.sessionWorking);
  });

  test('Tick when timer is running does increase the elapsed time', () async {
    ElapsedTimeCubit mockElapsedTimeCubit = MockElapsedTimeCubit();
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();
    Settings mockSettings = MockSettings();
    SharedPreferences.setMockInitialValues({});
    SharedPreferences prefs = await SharedPreferences.getInstance();

    when(mockTimerModel.isRunning()).thenReturn(true);
    when(mockTimerModel.isWorking).thenReturn(true);
    when(mockSettings.standingDesk).thenAnswer((_) => true);
    when(mockSettings.targetStandingMinutes).thenAnswer((_) => 100);
    when(mockHistoryRepo.getTodayIntervals()).thenAnswer((_) => []);
    when(mockTimerModel.state).thenReturn(TimerStates.noSession);
    when(mockElapsedTimeCubit.state).thenReturn(ElapsedTimeState(
        lastTickDateTime: null, elapsedTime: Duration(seconds: 0)));

    try {
      TimerScreenLogic.tick(
          // ignore: no-empty-block
          mockElapsedTimeCubit,
          mockTimerModel,
          mockHistoryRepo,
          mockSettings,
          prefs,
          isStanding: false,
          isDayChangeOnTick: AlwaysFalseIsDayChangeOnTick(),
          // ignore: no-empty-block
          onReachedStandingGoal: () {});
    } catch (e) {}

    verify(mockElapsedTimeCubit.onTick(addTime: true));
  });

  test('Tick stops session on day changed', () async {
    // Given
    ElapsedTimeCubit mockElapsedTimeCubit = MockElapsedTimeCubit();
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();
    Settings mockSettings = MockSettings();
    SharedPreferences.setMockInitialValues({});
    SharedPreferences prefs = await SharedPreferences.getInstance();

    when(mockTimerModel.isRunning()).thenReturn(true);
    when(mockTimerModel.isWorking).thenReturn(true);
    when(mockSettings.standingDesk).thenAnswer((_) => true);
    when(mockSettings.targetStandingMinutes).thenAnswer((_) => 100);
    when(mockHistoryRepo.getTodayIntervals()).thenAnswer((_) => []);
    when(mockTimerModel.state).thenReturn(TimerStates.sessionWorking);
    when(mockTimerModel.isRunning()).thenReturn(false);
    when(mockElapsedTimeCubit.state).thenReturn(ElapsedTimeState(
        lastTickDateTime: null, elapsedTime: Duration(seconds: 0)));

    // When
    TimerScreenLogic.tick(
        // ignore: no-empty-block
        mockElapsedTimeCubit,
        mockTimerModel,
        mockHistoryRepo,
        mockSettings,
        prefs,
        isStanding: false,
        isDayChangeOnTick: AlwaysTrueIsDayChangeOnTick(),
        // ignore: no-empty-block
        onReachedStandingGoal: () {});

    // Then
    verify(mockTimerModel.state = TimerStates.noSession);
  });

  test('Tick does not stop session on day changed', () async {
    // Given
    ElapsedTimeCubit mockElapsedTimeCubit = MockElapsedTimeCubit();
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();
    Settings mockSettings = MockSettings();
    SharedPreferences.setMockInitialValues({});
    SharedPreferences prefs = await SharedPreferences.getInstance();

    when(mockTimerModel.isRunning()).thenReturn(true);
    when(mockTimerModel.isWorking).thenReturn(true);
    when(mockSettings.standingDesk).thenAnswer((_) => true);
    when(mockSettings.targetStandingMinutes).thenAnswer((_) => 100);
    when(mockHistoryRepo.getTodayIntervals()).thenAnswer((_) => []);
    when(mockTimerModel.state).thenReturn(TimerStates.sessionWorking);
    when(mockTimerModel.isRunning()).thenReturn(false);
    when(mockElapsedTimeCubit.state).thenReturn(ElapsedTimeState(
        lastTickDateTime: null, elapsedTime: Duration(seconds: 0)));

    // When
    try {
      TimerScreenLogic.tick(
          // ignore: no-empty-block
          mockElapsedTimeCubit,
          mockTimerModel,
          mockHistoryRepo,
          mockSettings,
          prefs,
          isStanding: false,
          isDayChangeOnTick: AlwaysFalseIsDayChangeOnTick(),
          // ignore: no-empty-block
          onReachedStandingGoal: () {});
    } catch (e) {}

    // Then
    verifyNever(mockTimerModel.state = TimerStates.noSession);
  });

  test('Start session does nothing if session is there', () {
    ElapsedTimeCubit mockElapsedTimeCubit = MockElapsedTimeCubit();
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    TimerStates.values.forEach((timerState) {
      if (timerState == TimerStates.noSession) {
        return;
      }

      when(mockTimerModel.state).thenReturn(timerState);

      TimerScreenLogic.startWorkSession(
          mockElapsedTimeCubit, mockTimerModel, mockHistoryRepo);

      verifyNever(mockTimerModel.forceResume());
      verifyNever(mockTimerModel.state = TimerStates.sessionWorking);
      verifyZeroInteractions(mockElapsedTimeCubit);
      verifyZeroInteractions(mockHistoryRepo);
    });
  });

  test(
      'Start session resumes and starts a working session if no session currently',
      () {
    ElapsedTimeCubit mockElapsedTimeCubit = MockElapsedTimeCubit();
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    when(mockTimerModel.state).thenReturn(TimerStates.noSession);
    TimerScreenLogic.soundNotifier = MockBaseNotifier();

    TimerScreenLogic.startWorkSession(
        mockElapsedTimeCubit, mockTimerModel, mockHistoryRepo);

    verify(mockTimerModel.forceResume());
    verify(mockTimerModel.state = TimerStates.sessionWorking);
    verify(mockElapsedTimeCubit.reset());
    verify(mockHistoryRepo.startSession(IntervalType.work));
  });

  test(
      'Start session resumes and starts a working session if no session currently and paused',
      () {
    ElapsedTimeCubit mockElapsedTimeCubit = MockElapsedTimeCubit();
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    when(mockTimerModel.state).thenReturn(TimerStates.noSession);
    when(mockTimerModel.isPaused).thenReturn(true);
    TimerScreenLogic.soundNotifier = MockBaseNotifier();

    TimerScreenLogic.startWorkSession(
        mockElapsedTimeCubit, mockTimerModel, mockHistoryRepo);

    verify(mockTimerModel.forceResume());
    verify(mockTimerModel.state = TimerStates.sessionWorking);
    verify(mockElapsedTimeCubit.reset());
    verify(mockHistoryRepo.startSession(IntervalType.work));
  });

  test('Should ask if you are still standing if started standing while working',
      () {
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    when(mockTimerModel.state).thenReturn(TimerStates.sessionWorking);

    TimerScreenLogic.startStandingSessionByUser(
        mockHistoryRepo, mockTimerModel);

    when(mockTimerModel.state).thenReturn(TimerStates.sessionResting);

    expect(TimerScreenLogic.shouldAskStillStanding(true, mockTimerModel), true);
  });

  test('Should ask if you are still standing if started standing while working',
      () {
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    when(mockTimerModel.state).thenReturn(TimerStates.sessionWorking);

    TimerScreenLogic.startStandingSessionByUser(
        mockHistoryRepo, mockTimerModel);

    when(mockTimerModel.state).thenReturn(TimerStates.sessionResting);

    expect(TimerScreenLogic.shouldAskStillStanding(true, mockTimerModel), true);
  });

  test(
      'Should ask if you are still standing if started standing while working overtime',
      () {
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    when(mockTimerModel.state).thenReturn(TimerStates.sessionWorkingOvertime);

    TimerScreenLogic.startStandingSessionByUser(
        mockHistoryRepo, mockTimerModel);

    when(mockTimerModel.state).thenReturn(TimerStates.sessionResting);

    expect(TimerScreenLogic.shouldAskStillStanding(true, mockTimerModel), true);
  });

  test(
      'Should not ask if you are still standing if started standing during resting',
      () {
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    when(mockTimerModel.state).thenReturn(TimerStates.sessionResting);

    TimerScreenLogic.startStandingSessionByUser(
        mockHistoryRepo, mockTimerModel);

    expect(
        TimerScreenLogic.shouldAskStillStanding(true, mockTimerModel), false);
  });

  test(
      'Should not ask if you are still standing if started standing during resting overtime',
      () {
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    when(mockTimerModel.state).thenReturn(TimerStates.sessionRestingOvertime);

    TimerScreenLogic.startStandingSessionByUser(
        mockHistoryRepo, mockTimerModel);

    expect(
        TimerScreenLogic.shouldAskStillStanding(true, mockTimerModel), false);
  });

  test('Should not ask if you are still standing when not standing', () {
    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();

    when(mockTimerModel.state).thenReturn(TimerStates.sessionWorkingOvertime);

    TimerScreenLogic.startStandingSessionByUser(
        mockHistoryRepo, mockTimerModel);

    when(mockTimerModel.state).thenReturn(TimerStates.sessionRestingOvertime);

    expect(
        TimerScreenLogic.shouldAskStillStanding(false, mockTimerModel), false);
  });
}
