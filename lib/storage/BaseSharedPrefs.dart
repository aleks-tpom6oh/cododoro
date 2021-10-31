import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseSharedPrefs with ChangeNotifier {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    return _prefs != null
        ? Future.value(_prefs!)
        : SharedPreferences.getInstance();
  }
}
