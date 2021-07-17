import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  int _defaultWorkDuration = 55 * 60;
  int _defaultRestDuration = 5 * 60;

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) {
      return _prefs!;
    } else {
      return SharedPreferences.getInstance();
    }
  }

  Future<int> get workDuration async {
    return (await prefs).getInt("WORK_DURATION") ?? _defaultWorkDuration;
  }

  void setWorkDuration(newDuration) async {
    (await prefs).setInt("WORK_DURATION", newDuration);
  }

  Future<int> get restDuration async {
    return (await prefs).getInt("REST_DURATION") ?? _defaultRestDuration;
  }

  void setRestDuration(newDuration) async {
    (await prefs).setInt("REST_DURATION", newDuration);
  }
}
