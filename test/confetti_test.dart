import 'package:cododoro/common/cubit/elapsed_time_cubit.dart';
import 'package:cododoro/common/data_layer/persistent/history_repository.dart';
import 'package:cododoro/common/data_layer/persistent/settings.dart';
import 'package:cododoro/common/data_layer/timer_state_model.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cododoro/home_screen/view_model/timer_screen_logic.dart' as TimerScreenLogic;

class MockElapsedTimeCubit extends Mock implements ElapsedTimeCubit {}

class MockTimerStateModel extends Mock implements TimerStateModel {}

class MockHistoryRepository extends Mock implements HistoryRepository {}

class MockSettings extends Mock implements Settings {}

class MockConfettiController extends Mock implements ConfettiController {}

void main() {
  setUp(() async {
    // Set TimerScreenLogic._previousStandTimeTillGoal to 1

    TimerScreenLogic.notifiers = [];

    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();
    Settings mockSettings = MockSettings();

    TimerScreenLogic.confetti = MockConfettiController();

    when(() => mockSettings.standingDesk).thenAnswer((_) => true);
    when(() => mockHistoryRepo.getTodayIntervals()).thenAnswer((_) => {});
    when(() => mockSettings.targetStandingMinutes).thenAnswer((_) => 1);
    when(() => mockTimerModel.isWorking).thenAnswer((_) => true);

    WidgetsFlutterBinding.ensureInitialized();

    // When
    await TimerScreenLogic.notifyIfStandingGoalReached(
        mockTimerModel, mockSettings, mockHistoryRepo, true,
        // ignore: no-empty-block
        () {
      ;
    });
  });

  test(
      'Confetti is played once when targetStandingMinutes goes to -1 and then to -2',
      () async {
    // Given
    TimerScreenLogic.notifiers = [];

    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();
    Settings mockSettings = MockSettings();

    TimerScreenLogic.confetti = MockConfettiController();

    when(() => mockSettings.standingDesk).thenAnswer((_) => true);
    when(() => mockHistoryRepo.getTodayIntervals()).thenAnswer((_) => {});
    when(() => mockSettings.targetStandingMinutes).thenAnswer((_) => -1);
    when(() => mockTimerModel.isWorking).thenAnswer((_) => true);

    WidgetsFlutterBinding.ensureInitialized();

    int onReachStandingGoal = 0;

    // When
    await TimerScreenLogic.notifyIfStandingGoalReached(
        mockTimerModel, mockSettings, mockHistoryRepo, true,
        // ignore: no-empty-block
        () {
      onReachStandingGoal++;
    });

    // Then
    verify(() => TimerScreenLogic.confetti.play()).called(1);
    expect(onReachStandingGoal, 1);

    // When
    when(() => mockSettings.targetStandingMinutes).thenAnswer((_) => -2);
    await TimerScreenLogic.notifyIfStandingGoalReached(
        mockTimerModel, mockSettings, mockHistoryRepo, true,
        // ignore: no-empty-block
        () {
      onReachStandingGoal++;
    });

    // Then
    verifyNever(() => TimerScreenLogic.confetti.play());
    expect(onReachStandingGoal, 1);
  });

  test(
      'Confetti is played twice when targetStandingMinutes goes to -1 then to +1 and then to -2',
      () async {
    // Given
    TimerScreenLogic.notifiers = [];

    TimerStateModel mockTimerModel = MockTimerStateModel();
    HistoryRepository mockHistoryRepo = MockHistoryRepository();
    Settings mockSettings = MockSettings();

    TimerScreenLogic.confetti = MockConfettiController();

    when(() => mockSettings.standingDesk).thenAnswer((_) => true);
    when(() => mockHistoryRepo.getTodayIntervals()).thenAnswer((_) => {});
    when(() => mockSettings.targetStandingMinutes).thenAnswer((_) => -1);
    when(() => mockTimerModel.isWorking).thenAnswer((_) => true);

    WidgetsFlutterBinding.ensureInitialized();

    int onReachStandingGoal = 0;

    // When
    await TimerScreenLogic.notifyIfStandingGoalReached(
        mockTimerModel, mockSettings, mockHistoryRepo, true,
        // ignore: no-empty-block
        () {
      onReachStandingGoal++;
    });

    // Then
    verify(() => TimerScreenLogic.confetti.play()).called(1);
    expect(onReachStandingGoal, 1);

    // When
    when(() => mockSettings.targetStandingMinutes).thenAnswer((_) => 1);
    await TimerScreenLogic.notifyIfStandingGoalReached(
        mockTimerModel, mockSettings, mockHistoryRepo, true,
        // ignore: no-empty-block
        () {
      onReachStandingGoal++;
    });

    // Then
    verifyNever(() => TimerScreenLogic.confetti.play());
    expect(onReachStandingGoal, 1);

    // When
    when(() => mockSettings.targetStandingMinutes).thenAnswer((_) => -2);
    await TimerScreenLogic.notifyIfStandingGoalReached(
        mockTimerModel, mockSettings, mockHistoryRepo, true,
        // ignore: no-empty-block
        () {
      onReachStandingGoal++;
    });

    // Then
    verify(() => TimerScreenLogic.confetti.play()).called(1);
    expect(onReachStandingGoal, 2);
  });
}
