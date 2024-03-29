// Mocks generated by Mockito 5.0.15 from annotations
// in cododoro/test/timer_screen_logic_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i5;
import 'dart:ui' as _i9;

import 'package:bloc/bloc.dart' as _i6;
import 'package:cododoro/common/cubit/elapsed_time_cubit.dart' as _i4;
import 'package:cododoro/common/cubit/elapsed_time_state.dart' as _i2;
import 'package:cododoro/common/data_layer/persistent/history_repository.dart'
    as _i10;
import 'package:cododoro/common/data_layer/persistent/settings.dart' as _i11;
import 'package:cododoro/common/data_layer/timer_state_model.dart' as _i7;
import 'package:cododoro/common/data_layer/timer_states.dart' as _i8;
import 'package:cododoro/notifications/base_notifier.dart' as _i12;
import 'package:mockito/mockito.dart' as _i1;
import 'package:shared_preferences/shared_preferences.dart' as _i3;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis

class _FakeElapsedTimeState_0 extends _i1.Fake implements _i2.ElapsedTimeState {
}

class _FakeSharedPreferences_1 extends _i1.Fake
    implements _i3.SharedPreferences {}

/// A class which mocks [ElapsedTimeCubit].
///
/// See the documentation for Mockito's code generation for more information.
class MockElapsedTimeCubit extends _i1.Mock implements _i4.ElapsedTimeCubit {
  MockElapsedTimeCubit() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.ElapsedTimeState get state =>
      (super.noSuchMethod(Invocation.getter(#state),
          returnValue: _FakeElapsedTimeState_0()) as _i2.ElapsedTimeState);
  @override
  _i5.Stream<_i2.ElapsedTimeState> get stream =>
      (super.noSuchMethod(Invocation.getter(#stream),
              returnValue: Stream<_i2.ElapsedTimeState>.empty())
          as _i5.Stream<_i2.ElapsedTimeState>);
  @override
  bool get isClosed =>
      (super.noSuchMethod(Invocation.getter(#isClosed), returnValue: false)
          as bool);
  @override
  void reset() => super.noSuchMethod(Invocation.method(#reset, []),
      returnValueForMissingStub: null);
  @override
  void onTick({bool? addTime}) =>
      super.noSuchMethod(Invocation.method(#onTick, [], {#addTime: addTime}),
          returnValueForMissingStub: null);
  @override
  void emit(_i2.ElapsedTimeState? state) =>
      super.noSuchMethod(Invocation.method(#emit, [state]),
          returnValueForMissingStub: null);
  @override
  void onChange(_i6.Change<_i2.ElapsedTimeState>? change) =>
      super.noSuchMethod(Invocation.method(#onChange, [change]),
          returnValueForMissingStub: null);
  @override
  void addError(Object? error, [StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#addError, [error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void onError(Object? error, StackTrace? stackTrace) =>
      super.noSuchMethod(Invocation.method(#onError, [error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  _i5.Future<void> close() => (super.noSuchMethod(Invocation.method(#close, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  String toString() => super.toString();
}

/// A class which mocks [TimerStateModel].
///
/// See the documentation for Mockito's code generation for more information.
class MockTimerStateModel extends _i1.Mock implements _i7.TimerStateModel {
  MockTimerStateModel() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.TimerStates get state => (super.noSuchMethod(Invocation.getter(#state),
      returnValue: _i8.TimerStates.sessionWorking) as _i8.TimerStates);
  @override
  set state(dynamic newState) =>
      super.noSuchMethod(Invocation.setter(#state, newState),
          returnValueForMissingStub: null);
  @override
  bool get isPaused =>
      (super.noSuchMethod(Invocation.getter(#isPaused), returnValue: false)
          as bool);
  @override
  bool get isWorking =>
      (super.noSuchMethod(Invocation.getter(#isWorking), returnValue: false)
          as bool);
  @override
  bool get isOvertime =>
      (super.noSuchMethod(Invocation.getter(#isOvertime), returnValue: false)
          as bool);
  @override
  bool get isResting =>
      (super.noSuchMethod(Invocation.getter(#isResting), returnValue: false)
          as bool);
  @override
  bool get isChilling =>
      (super.noSuchMethod(Invocation.getter(#isChilling), returnValue: false)
          as bool);
  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);
  @override
  bool isRunning() =>
      (super.noSuchMethod(Invocation.method(#isRunning, []), returnValue: false)
          as bool);
  @override
  void pauseResume() => super.noSuchMethod(Invocation.method(#pauseResume, []),
      returnValueForMissingStub: null);
  @override
  void forceResume() => super.noSuchMethod(Invocation.method(#forceResume, []),
      returnValueForMissingStub: null);
  @override
  String toString() => super.toString();
  @override
  void addListener(_i9.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void removeListener(_i9.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#removeListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void dispose() => super.noSuchMethod(Invocation.method(#dispose, []),
      returnValueForMissingStub: null);
  @override
  void notifyListeners() =>
      super.noSuchMethod(Invocation.method(#notifyListeners, []),
          returnValueForMissingStub: null);
}

/// A class which mocks [HistoryRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockHistoryRepository extends _i1.Mock implements _i10.HistoryRepository {
  MockHistoryRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.SharedPreferences get prefs =>
      (super.noSuchMethod(Invocation.getter(#prefs),
          returnValue: _FakeSharedPreferences_1()) as _i3.SharedPreferences);
  @override
  set prefs(_i3.SharedPreferences? _prefs) =>
      super.noSuchMethod(Invocation.setter(#prefs, _prefs),
          returnValueForMissingStub: null);
  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);
  @override
  void startSession(_i10.IntervalType? type) =>
      super.noSuchMethod(Invocation.method(#startSession, [type]),
          returnValueForMissingStub: null);
  @override
  void stopStanding() =>
      super.noSuchMethod(Invocation.method(#stopStanding, []),
          returnValueForMissingStub: null);
  @override
  void saveSession(DateTime? startTime, DateTime? endTime,
          _i10.IntervalType? type, Duration? duration) =>
      super.noSuchMethod(
          Invocation.method(#saveSession, [startTime, endTime, type, duration]),
          returnValueForMissingStub: null);
  @override
  void updateCurrentStandingSession({bool? addTime = true}) =>
      super.noSuchMethod(
          Invocation.method(
              #updateCurrentStandingSession, [], {#addTime: addTime}),
          returnValueForMissingStub: null);
  @override
  void updateCurrentPomodoroSession(DateTime? endTime, Duration? duration) =>
      super.noSuchMethod(
          Invocation.method(#updateCurrentPomodoroSession, [endTime, duration]),
          returnValueForMissingStub: null);
  @override
  void toggleSessionType(_i10.Interval? interval) =>
      super.noSuchMethod(Invocation.method(#toggleSessionType, [interval]),
          returnValueForMissingStub: null);
  @override
  bool removeSession(_i10.Interval? interval) =>
      (super.noSuchMethod(Invocation.method(#removeSession, [interval]),
          returnValue: false) as bool);
  @override
  Iterable<_i10.StoredInterval> getTodayIntervals() => (super.noSuchMethod(
      Invocation.method(#getTodayIntervals, []),
      returnValue: <_i10.StoredInterval>[]) as Iterable<_i10.StoredInterval>);
  @override
  String toString() => super.toString();
  @override
  void addListener(_i9.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void removeListener(_i9.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#removeListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void dispose() => super.noSuchMethod(Invocation.method(#dispose, []),
      returnValueForMissingStub: null);
  @override
  void notifyListeners() =>
      super.noSuchMethod(Invocation.method(#notifyListeners, []),
          returnValueForMissingStub: null);
}

/// A class which mocks [Settings].
///
/// See the documentation for Mockito's code generation for more information.
class MockSettings extends _i1.Mock implements _i11.Settings {
  MockSettings() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.SharedPreferences get prefs =>
      (super.noSuchMethod(Invocation.getter(#prefs),
          returnValue: _FakeSharedPreferences_1()) as _i3.SharedPreferences);
  @override
  set prefs(_i3.SharedPreferences? _prefs) =>
      super.noSuchMethod(Invocation.setter(#prefs, _prefs),
          returnValueForMissingStub: null);
  @override
  int get workDurationSeconds =>
      (super.noSuchMethod(Invocation.getter(#workDuration), returnValue: 0)
          as int);
  @override
  int get restDuration =>
      (super.noSuchMethod(Invocation.getter(#restDuration), returnValue: 0)
          as int);
  @override
  bool get standingDesk =>
      (super.noSuchMethod(Invocation.getter(#standingDesk), returnValue: false)
          as bool);
  @override
  bool get showCuteCats =>
      (super.noSuchMethod(Invocation.getter(#showCuteCats), returnValue: false)
          as bool);
  @override
  int get targetStandingMinutes =>
      (super.noSuchMethod(Invocation.getter(#targetStandingMinutes),
          returnValue: 0) as int);
  @override
  int get dayHoursOffset =>
      (super.noSuchMethod(Invocation.getter(#dayHoursOffset), returnValue: 0)
          as int);
  @override
  int get targetWorkingMinutes =>
      (super.noSuchMethod(Invocation.getter(#targetWorkingMinutes),
          returnValue: 0) as int);
  @override
  int get standingReminderHour =>
      (super.noSuchMethod(Invocation.getter(#standingReminderHour),
          returnValue: 0) as int);
  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);
  @override
  void setWorkDurationSeconds(int? newDuration) =>
      super.noSuchMethod(Invocation.method(#setWorkDuration, [newDuration]),
          returnValueForMissingStub: null);
  @override
  void setRestDuration(int? newDuration) =>
      super.noSuchMethod(Invocation.method(#setRestDuration, [newDuration]),
          returnValueForMissingStub: null);
  @override
  void setStandingDesk(bool? newStandingDesk) =>
      super.noSuchMethod(Invocation.method(#setStandingDesk, [newStandingDesk]),
          returnValueForMissingStub: null);
  @override
  void setShowCuteCats(bool? newShowCuteCats) =>
      super.noSuchMethod(Invocation.method(#setShowCuteCats, [newShowCuteCats]),
          returnValueForMissingStub: null);
  @override
  void setTargetStandingMinutes(int? newTargetStandingMinutes) =>
      super.noSuchMethod(
          Invocation.method(
              #setTargetStandingMinutes, [newTargetStandingMinutes]),
          returnValueForMissingStub: null);
  @override
  void setDayHoursOffset(int? newDayHoursOffset) => super.noSuchMethod(
      Invocation.method(#setDayHoursOffset, [newDayHoursOffset]),
      returnValueForMissingStub: null);
  @override
  void setTargetWorkingMinutes(int? newTargetWorkingMinutes) =>
      super.noSuchMethod(
          Invocation.method(
              #setTargetWorkingMinutes, [newTargetWorkingMinutes]),
          returnValueForMissingStub: null);
  @override
  void setStandingReminderHour(int? newStandingReminderHour) =>
      super.noSuchMethod(
          Invocation.method(
              #setStandingReminderHour, [newStandingReminderHour]),
          returnValueForMissingStub: null);
  @override
  String toString() => super.toString();
  @override
  void addListener(_i9.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void removeListener(_i9.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#removeListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void dispose() => super.noSuchMethod(Invocation.method(#dispose, []),
      returnValueForMissingStub: null);
  @override
  void notifyListeners() =>
      super.noSuchMethod(Invocation.method(#notifyListeners, []),
          returnValueForMissingStub: null);
}

/// A class which mocks [BaseNotifier].
///
/// See the documentation for Mockito's code generation for more information.
class MockBaseNotifier extends _i1.Mock implements _i12.BaseNotifier {
  MockBaseNotifier() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<void> notify(String? message,
          {String? soundPath, Duration? delay = Duration.zero}) =>
      (super.noSuchMethod(
          Invocation.method(
              #notify, [message], {#soundPath: soundPath, #delay: delay}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  void dispose() => super.noSuchMethod(Invocation.method(#dispose, []),
      returnValueForMissingStub: null);
  @override
  String toString() => super.toString();
}
