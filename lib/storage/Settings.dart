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

  /* Future< */int/* > */ get workDuration /* async */ {
    return /*(await prefs)*/prefs.getInt("WORK_DURATION") ?? _defaultWorkDuration;
  }

  void setWorkDuration(int newDuration) /* async */ {
    /*(await prefs)*/ prefs.setInt("WORK_DURATION", newDuration);
    notifyListeners();
  }

  /* Future<int> */int get restDuration /* async */ {
    return /*(await prefs)*/prefs.getInt("REST_DURATION") ?? _defaultRestDuration;
  }

  void setRestDuration(int newDuration) /* async */ {
    /*(await prefs)*/prefs.setInt("REST_DURATION", newDuration);
    notifyListeners();
  }

  /* Future< */bool/* > */ get standingDesk /* async */ {
    return /*(await prefs)*/prefs.getBool("STANDING_DESK") ?? _defaulStandingDesk;
  }

  void setStandingDesk(bool newStandingDesk) {
    /*(await prefs)*/prefs.setBool("STANDING_DESK", newStandingDesk);
    notifyListeners();
  }

  int get targetStandingMinutes  {
    final int? legacyHoursSetting =
        /*(await prefs)*/prefs.getInt("TARGET_STANDING_HOURS");
    final int? legacyHoursInMinutes =
        legacyHoursSetting != null ? legacyHoursSetting * 60 : null;

    return /*(await prefs)*/prefs.getInt("TARGET_STANDING_MINUTES") ??
        legacyHoursInMinutes ??
        _defaulTargetStandingMinutes;
  }

  void setTargetStandingMinutes(int newTargetStandingMinutes)  {
    /*(await prefs)*/prefs
        .setInt("TARGET_STANDING_MINUTES", newTargetStandingMinutes);
    notifyListeners();
  }

  int get dayHoursOffset  {
    return getDayHoursOffset/*(await prefs)*/(prefs);
  }

  void setDayHoursOffset(int newDayHoursOffset) {
    /*(await prefs)*/prefs.setInt(dayHoursOffsetKey, newDayHoursOffset);
    notifyListeners();
  }
}
