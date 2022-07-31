// ignore: unused_import
import 'package:meta/meta.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'elapsed_time_state.freezed.dart';

@freezed
class ElapsedTimeState with _$ElapsedTimeState {

    const factory ElapsedTimeState({
      required  DateTime? lastTickDateTime,
      required Duration elapsedTime,
    }) = _ElapsedTimeState;

/*   int get elapsedTime.inSeconds {
    return this.elapsedTime.inSeconds;
  }

  int get elapsedTimeMs {
    return this.elapsedTime.inMilliseconds;
  } */
}
