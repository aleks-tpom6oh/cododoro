import 'package:cododoro/data_layer/cubit/elapsed_time_cubit.dart';
import 'package:test/test.dart';

void main() {
  test(
      'ElapsedTimeModel does not increase elapsed time if tick with addTime = false',
      () {
    final elapsedTimeCubit = ElapsedTimeCubit();

    final initialElapsedTime = elapsedTimeCubit.state.elapsedTime.inMilliseconds;

    elapsedTimeCubit.onTick(addTime: false);

    expect(elapsedTimeCubit.state.elapsedTime.inMilliseconds, equals(initialElapsedTime));
  });

  test('ElapsedTimeModel increases elapsed time if tick with addTime = true',
      () {
    final elapsedTimeCubit = ElapsedTimeCubit();

    final initialElapsedTime = elapsedTimeCubit.state.elapsedTime.inMilliseconds;

    elapsedTimeCubit.onTick(addTime: true);

    expect(elapsedTimeCubit.state.elapsedTime.inMilliseconds, greaterThan(initialElapsedTime));
  });
}
