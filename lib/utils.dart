import 'package:cododoro/storage/HistoryRepository.dart';

stopwatchTime(Duration d) => d.toString().split('.').first.padLeft(8, "0");

extension Summer on Iterable<int> {
  int sum() {
    return (this.isEmpty)
        ? 0
        : this.reduce(
            (value, workIntervalDuration) => value + workIntervalDuration);
  }
}

extension DurationPrinter on Duration {
  String toHmsString() {
    int hours = this.inHours;
    int minutes = this.inMinutes - hours * 60;
    int seconds = this.inSeconds - this.inMinutes * 60;
    return "$hours hours, $minutes minutes, $seconds seconds";
  }
}

Duration calculateTimeForIntervalType(
    Iterable<PomodoroInterval>? intervals, IntervalType intervalType) {
  return Duration(
      seconds: (intervals ?? [])
          .where((interval) => interval.type == intervalType)
          .map((interval) => interval.duration.inSeconds)
          .sum());
}