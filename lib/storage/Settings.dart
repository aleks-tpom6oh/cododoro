import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String dayHoursOffsetKey = "DAY_HOURS_OFFSET";
const String workDurationKey = "WORK_DURATION";
const String restDurationKey = "REST_DURATION";
const String standingDeskKey = "STANDING_DESK";
const String showCuteCatsKey = "SHOW_CUTE_CATS";
const String targetStandingMinutesKey = "TARGET_STANDING_MINUTES";
const String targetWorkingMinutesKey = "TARGET_WORKING_MINUTES";

int _defaultDayHoursOffset = 4;

int getDayHoursOffset(SharedPreferences prefs) {
  return prefs.getInt(dayHoursOffsetKey) ?? _defaultDayHoursOffset;
}

class Settings with ChangeNotifier {
  SharedPreferences prefs;

  Settings({required this.prefs});

  int _defaultWorkDuration = Duration(minutes: 50).inSeconds;
  int _defaultRestDuration = Duration(minutes: 10).inSeconds;

  int _defaulTargetStandingMinutes = Duration(minutes: 100).inMinutes;
  int _defaulTargetWorkingMinutes = Duration(hours: 6).inMinutes;

  bool _defaulStandingDesk = true;

  bool _defaulShowCuteCats = true;

  int get workDuration {
    return prefs.getInt(workDurationKey) ?? _defaultWorkDuration;
  }

  void setWorkDuration(int newDuration) {
    prefs.setInt(workDurationKey, newDuration);
    notifyListeners();
  }

  int get restDuration {
    return prefs.getInt(restDurationKey) ?? _defaultRestDuration;
  }

  void setRestDuration(int newDuration) {
    prefs.setInt(restDurationKey, newDuration);
    notifyListeners();
  }

  bool get standingDesk {
    return prefs.getBool(standingDeskKey) ?? _defaulStandingDesk;
  }

  void setStandingDesk(bool newStandingDesk) {
    prefs.setBool(standingDeskKey, newStandingDesk);
    notifyListeners();
  }

  bool get showCuteCats {
    return prefs.getBool(showCuteCatsKey) ?? _defaulShowCuteCats;
  }

  void setShowCuteCats(bool newShowCuteCats) {
    prefs.setBool(showCuteCatsKey, newShowCuteCats);
    notifyListeners();
  }

  int get targetStandingMinutes {
    final int? legacyHoursSetting = prefs.getInt("TARGET_STANDING_HOURS");
    final int? legacyHoursInMinutes =
        legacyHoursSetting != null ? legacyHoursSetting * 60 : null;

    return prefs.getInt(targetStandingMinutesKey) ??
        legacyHoursInMinutes ??
        _defaulTargetStandingMinutes;
  }

  void setTargetStandingMinutes(int newTargetStandingMinutes) {
    prefs.setInt(targetStandingMinutesKey, newTargetStandingMinutes);
    notifyListeners();
  }

  int get dayHoursOffset {
    return getDayHoursOffset(prefs);
  }

  void setDayHoursOffset(int newDayHoursOffset) {
    prefs.setInt(dayHoursOffsetKey, newDayHoursOffset);
    notifyListeners();
  }

  int get targetWorkingMinutes {
    return prefs.getInt(targetWorkingMinutesKey) ?? _defaulTargetWorkingMinutes;
  }

  void setTargetWorkingMinutes(int newTargetWorkingMinutes) {
    prefs.setInt(targetWorkingMinutesKey, newTargetWorkingMinutes);
    notifyListeners();
  }
}
