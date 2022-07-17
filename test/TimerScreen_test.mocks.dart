// Mocks generated by Mockito 5.0.15 from annotations
// in cododoro/test/TimerScreen_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:cododoro/notifiers/BaseNotifier.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis

/// A class which mocks [BaseNotifier].
///
/// See the documentation for Mockito's code generation for more information.
class MockBaseNotifier extends _i1.Mock implements _i2.BaseNotifier {
  MockBaseNotifier() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> notify(String? message,
          {String? soundPath, Duration? delay = const Duration(seconds: 0)}) =>
      (super.noSuchMethod(
          Invocation.method(
              #notify, [message], {#soundPath: soundPath, #delay: delay}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  void dispose() => super.noSuchMethod(Invocation.method(#dispose, []),
      returnValueForMissingStub: null);
  @override
  String toString() => super.toString();
}
