import 'package:cododoro/storage/Settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

DateTime lastTickTime = DateTime.now();
isDayChangeOnTick(DateTime newTickTime, SharedPreferences prefs) {
  final hoursOffset = getDayHoursOffset(prefs);
  final prevTickTimeAdjustedHour =
      lastTickTime.subtract(Duration(hours: hoursOffset)).hour;
  final newTickTimeAdjustedHour =
      newTickTime.subtract(Duration(hours: hoursOffset)).hour;

  if (prevTickTimeAdjustedHour > newTickTimeAdjustedHour) {
    print("lastTickTime " + lastTickTime.toIso8601String());
    print("newTickTime " + newTickTime.toIso8601String());

    print("lastTickTimeAdjustedHour $prevTickTimeAdjustedHour");
    print("newTickTimeAdjustedHour $newTickTimeAdjustedHour");
  }

  lastTickTime = newTickTime;

  return prevTickTimeAdjustedHour > newTickTimeAdjustedHour;
}