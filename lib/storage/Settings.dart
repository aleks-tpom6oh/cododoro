import 'package:cododoro/storage/BaseSharedPrefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String dayHoursOffsetKey = "DAY_HOURS_OFFSET";

int _defaultDayHoursOffset = 4;

int getDayHoursOffset(SharedPreferences prefs) {
  return prefs.getInt(dayHoursOffsetKey) ?? _defaultDayHoursOffset;
}

class Settings extends BaseSharedPrefs {
  int _defaultWorkDuration = 50 * 60;
  int _defaultRestDuration = 10 * 60;

  int _defaulTargetStandingMinutes = 100;

  bool _defaulStandingDesk = true;

  Future<int> get workDuration async {
    return (await prefs).getInt("WORK_DURATION") ?? _defaultWorkDuration;
  }

  void setWorkDuration(int newDuration) async {
    (await prefs).setInt("WORK_DURATION", newDuration);
    notifyListeners();
  }

  Future<int> get restDuration async {
    return (await prefs).getInt("REST_DURATION") ?? _defaultRestDuration;
  }

  void setRestDuration(int newDuration) async {
    (await prefs).setInt("REST_DURATION", newDuration);
    notifyListeners();
  }

  Future<bool> get standingDesk async {
    return (await prefs).getBool("STANDING_DESK") ?? _defaulStandingDesk;
  }

  void setStandingDesk(bool newStandingDesk) async {
    await (await prefs).setBool("STANDING_DESK", newStandingDesk);
    notifyListeners();
  }

  Future<int> get targetStandingMinutes async {
    final int? legacyHoursSetting =
        (await prefs).getInt("TARGET_STANDING_HOURS");
    final int? legacyHoursInMinutes =
        legacyHoursSetting != null ? legacyHoursSetting * 60 : null;

    return (await prefs).getInt("TARGET_STANDING_MINUTES") ??
        legacyHoursInMinutes ??
        _defaulTargetStandingMinutes;
  }

  void setTargetStandingMinutes(int newTargetStandingMinutes) async {
    await (await prefs)
        .setInt("TARGET_STANDING_MINUTES", newTargetStandingMinutes);
    notifyListeners();
  }

  Future<int> get dayHoursOffset async {
    return getDayHoursOffset(await prefs);
  }

  void setDayHoursOffset(int newDayHoursOffset) async {
    await (await prefs).setInt(dayHoursOffsetKey, newDayHoursOffset);
    notifyListeners();
  }
}
