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

    String res = "";

    if (hours > 0) {
      res += "$hours hour${hours == 1 ? '' : 's'}, ";
    }
    if (hours > 0 || minutes > 0) {
      res += "$minutes minute${minutes == 1 ? '' : 's'}, ";
    }

    return res + "$seconds second${seconds == 1 ? '' : 's'}";
  }

  String toShortHmsString() {
    int hours = this.inHours;
    int minutes = this.inMinutes - hours * 60;
    int seconds = this.inSeconds - this.inMinutes * 60;

    String res = "";

    if (hours > 0) {
      res += "${hours}h";
    }
    if (hours > 0 || minutes > 0) {
      res += "${minutes}m";
    }

    return res + "${seconds}s";
  }

  String toMsString() {
    int hours = this.inHours;
    int minutes = this.inMinutes - hours * 60;
    int seconds = this.inSeconds - this.inMinutes * 60;

    String res = "";

    if (hours > 0 || minutes > 0) {
      res += "${hours * 60 + minutes} minute${minutes % 10 == 1 ? '' : 's'}, ";
    }

    return res + "$seconds second${seconds % 10 == 1 ? '' : 's'}";
  }

  String toShortMsString() {
    int hours = this.inHours;
    int minutes = this.inMinutes - hours * 60;
    int seconds = this.inSeconds - this.inMinutes * 60;

    String res = "";

    if (hours > 0 || minutes > 0) {
      res += "${hours * 60 + minutes}m";
    }

    return res + "${seconds}s";
  }
}

Duration calculateTimeForIntervalType(
    Iterable<StoredInterval>? intervals, IntervalType intervalType) {
  return Duration(
      seconds: (intervals ?? [])
          .where((interval) => interval.type == intervalType)
          .map((interval) => interval.duration.inSeconds)
          .sum());
}
