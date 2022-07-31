import 'package:freezed_annotation/freezed_annotation.dart';

part 'elapsed_time_state.freezed.dart';

@freezed
class ElapsedTimeState with _$ElapsedTimeState {

    const factory ElapsedTimeState({
      required  DateTime? lastTickDateTime,
      required Duration elapsedTime,
    }) = _ElapsedTimeState;
}
