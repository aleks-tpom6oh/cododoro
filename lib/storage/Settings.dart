import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String dayHoursOffsetKey = "DAY_HOURS_OFFSET";

int _defaultDayHoursOffset = 4;

int getDayHoursOffset(SharedPreferences prefs) {
  return prefs.getInt(dayHoursOffsetKey) ?? _defaultDayHoursOffset;
}

class Settings with ChangeNotifier {
  SharedPreferences prefs;

  Settings({required this.prefs});

  int _defaultWorkDuration = 50 * 60;
  int _defaultRestDuration = 10 * 60;

  int _defaulTargetStandingMinutes = 100;

  bool _defaulStandingDesk = true;

  int get workDuration {
    return prefs.getInt("WORK_DURATION") ?? _defaultWorkDuration;
  }

  void setWorkDuration(int newDuration) {
    prefs.setInt("WORK_DURATION", newDuration);
    notifyListeners();
  }

  int get restDuration {
    return prefs.getInt("REST_DURATION") ?? _defaultRestDuration;
  }

  void setRestDuration(int newDuration) {
    prefs.setInt("REST_DURATION", newDuration);
    notifyListeners();
  }

  bool get standingDesk {
    return prefs.getBool("STANDING_DESK") ?? _defaulStandingDesk;
  }

  void setStandingDesk(bool newStandingDesk) {
    prefs.setBool("STANDING_DESK", newStandingDesk);
    notifyListeners();
  }

  int get targetStandingMinutes {
    final int? legacyHoursSetting = prefs.getInt("TARGET_STANDING_HOURS");
    final int? legacyHoursInMinutes =
        legacyHoursSetting != null ? legacyHoursSetting * 60 : null;

    return prefs.getInt("TARGET_STANDING_MINUTES") ??
        legacyHoursInMinutes ??
        _defaulTargetStandingMinutes;
  }

  void setTargetStandingMinutes(int newTargetStandingMinutes) {
    prefs.setInt("TARGET_STANDING_MINUTES", newTargetStandingMinutes);
    notifyListeners();
  }

  int get dayHoursOffset {
    return getDayHoursOffset(prefs);
  }

  void setDayHoursOffset(int newDayHoursOffset) {
    prefs.setInt(dayHoursOffsetKey, newDayHoursOffset);
    notifyListeners();
  }
}
