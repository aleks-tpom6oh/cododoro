import 'package:cododoro/common/data_layer/persistent/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IsDayChangeOnTick {
  DateTime lastTickTime = DateTime.now();
  isDayChangeOnTick(DateTime newTickTime, SharedPreferences prefs) {
    final hoursOffset = getDayHoursOffset(prefs);
    final prevTickTimeAdjustedHour =
        lastTickTime.subtract(Duration(hours: hoursOffset)).hour;
    final newTickTimeAdjustedHour =
        newTickTime.subtract(Duration(hours: hoursOffset)).hour;

    lastTickTime = newTickTime;

    return prevTickTimeAdjustedHour > newTickTimeAdjustedHour;
  }
}
