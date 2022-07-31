// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'elapsed_time_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$ElapsedTimeStateTearOff {
  const _$ElapsedTimeStateTearOff();

  _ElapsedTimeState call(
      {required DateTime? lastTickDateTime, required Duration elapsedTime}) {
    return _ElapsedTimeState(
      lastTickDateTime: lastTickDateTime,
      elapsedTime: elapsedTime,
    );
  }
}

/// @nodoc
const $ElapsedTimeState = _$ElapsedTimeStateTearOff();

/// @nodoc
mixin _$ElapsedTimeState {
  DateTime? get lastTickDateTime => throw _privateConstructorUsedError;
  Duration get elapsedTime => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ElapsedTimeStateCopyWith<ElapsedTimeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ElapsedTimeStateCopyWith<$Res> {
  factory $ElapsedTimeStateCopyWith(
          ElapsedTimeState value, $Res Function(ElapsedTimeState) then) =
      _$ElapsedTimeStateCopyWithImpl<$Res>;
  $Res call({DateTime? lastTickDateTime, Duration elapsedTime});
}

/// @nodoc
class _$ElapsedTimeStateCopyWithImpl<$Res>
    implements $ElapsedTimeStateCopyWith<$Res> {
  _$ElapsedTimeStateCopyWithImpl(this._value, this._then);

  final ElapsedTimeState _value;
  // ignore: unused_field
  final $Res Function(ElapsedTimeState) _then;

  @override
  $Res call({
    Object? lastTickDateTime = freezed,
    Object? elapsedTime = freezed,
  }) {
    return _then(_value.copyWith(
      lastTickDateTime: lastTickDateTime == freezed
          ? _value.lastTickDateTime
          : lastTickDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      elapsedTime: elapsedTime == freezed
          ? _value.elapsedTime
          : elapsedTime // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc
abstract class _$ElapsedTimeStateCopyWith<$Res>
    implements $ElapsedTimeStateCopyWith<$Res> {
  factory _$ElapsedTimeStateCopyWith(
          _ElapsedTimeState value, $Res Function(_ElapsedTimeState) then) =
      __$ElapsedTimeStateCopyWithImpl<$Res>;
  @override
  $Res call({DateTime? lastTickDateTime, Duration elapsedTime});
}

/// @nodoc
class __$ElapsedTimeStateCopyWithImpl<$Res>
    extends _$ElapsedTimeStateCopyWithImpl<$Res>
    implements _$ElapsedTimeStateCopyWith<$Res> {
  __$ElapsedTimeStateCopyWithImpl(
      _ElapsedTimeState _value, $Res Function(_ElapsedTimeState) _then)
      : super(_value, (v) => _then(v as _ElapsedTimeState));

  @override
  _ElapsedTimeState get _value => super._value as _ElapsedTimeState;

  @override
  $Res call({
    Object? lastTickDateTime = freezed,
    Object? elapsedTime = freezed,
  }) {
    return _then(_ElapsedTimeState(
      lastTickDateTime: lastTickDateTime == freezed
          ? _value.lastTickDateTime
          : lastTickDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      elapsedTime: elapsedTime == freezed
          ? _value.elapsedTime
          : elapsedTime // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc

class _$_ElapsedTimeState implements _ElapsedTimeState {
  const _$_ElapsedTimeState(
      {required this.lastTickDateTime, required this.elapsedTime});

  @override
  final DateTime? lastTickDateTime;
  @override
  final Duration elapsedTime;

  @override
  String toString() {
    return 'ElapsedTimeState(lastTickDateTime: $lastTickDateTime, elapsedTime: $elapsedTime)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ElapsedTimeState &&
            const DeepCollectionEquality()
                .equals(other.lastTickDateTime, lastTickDateTime) &&
            const DeepCollectionEquality()
                .equals(other.elapsedTime, elapsedTime));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(lastTickDateTime),
      const DeepCollectionEquality().hash(elapsedTime));

  @JsonKey(ignore: true)
  @override
  _$ElapsedTimeStateCopyWith<_ElapsedTimeState> get copyWith =>
      __$ElapsedTimeStateCopyWithImpl<_ElapsedTimeState>(this, _$identity);
}

abstract class _ElapsedTimeState implements ElapsedTimeState {
  const factory _ElapsedTimeState(
      {required DateTime? lastTickDateTime,
      required Duration elapsedTime}) = _$_ElapsedTimeState;

  @override
  DateTime? get lastTickDateTime;
  @override
  Duration get elapsedTime;
  @override
  @JsonKey(ignore: true)
  _$ElapsedTimeStateCopyWith<_ElapsedTimeState> get copyWith =>
      throw _privateConstructorUsedError;
}
