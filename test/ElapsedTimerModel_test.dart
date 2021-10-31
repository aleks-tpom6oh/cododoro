import 'package:cododoro/models/ElapsedTimeModel.dart';
import 'package:test/test.dart';

void main() {
  test(
      'ElapsedTimeModel does not increase elapsed time if tick with addTime = false',
      () {
    final elapsedTimeModel = ElapsedTimeModel();

    final initialElapsedTime = elapsedTimeModel.elapsedTimeMs;

    elapsedTimeModel.onTick(addTime: false);

    expect(elapsedTimeModel.elapsedTimeMs, equals(initialElapsedTime));
  });

  test('ElapsedTimeModel increases elapsed time if tick with addTime = true',
      () {
    final elapsedTimeModel = ElapsedTimeModel();

    final initialElapsedTime = elapsedTimeModel.elapsedTimeMs;

    elapsedTimeModel.onTick(addTime: true);

    expect(elapsedTimeModel.elapsedTimeMs, greaterThan(initialElapsedTime));
  });
}
