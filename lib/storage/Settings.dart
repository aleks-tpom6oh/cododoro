import 'package:programadoro/storage/BaseSharedPrefs.dart';

class Settings extends BaseSharedPrefs {
  int _defaultWorkDuration = 55 * 60;
  int _defaultRestDuration = 5 * 60;

  Future<int> get workDuration async {
    return (await prefs).getInt("WORK_DURATION") ?? _defaultWorkDuration;
  }

  void setWorkDuration(newDuration) async {
    (await prefs).setInt("WORK_DURATION", newDuration);
    notifyListeners();
  }

  Future<int> get restDuration async {
    return (await prefs).getInt("REST_DURATION") ?? _defaultRestDuration;
  }

  void setRestDuration(newDuration) async {
    (await prefs).setInt("REST_DURATION", newDuration);
    notifyListeners();
  }
}
