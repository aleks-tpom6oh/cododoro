import 'package:cododoro/data_layer/storage/BaseSharedPrefs.dart';
import 'package:flutter/material.dart';

enum ThemeSetting { system, light, dark }

final lightTheme = ThemeData(
    primaryColor: Color(0xFFD6D4DB),
    primarySwatch: Colors.blueGrey,
    fontFamily: 'CourierPrime',
    scaffoldBackgroundColor: const Color(0xFFFFFCEA));

final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF261A30),
    fontFamily: 'CourierPrime',
    textTheme: TextTheme(
      bodyText1: TextStyle(),
      bodyText2: TextStyle(),
    ).apply(
      bodyColor: const Color(0xFFFF756C), //FF71DF
    ),
    scaffoldBackgroundColor: const Color(0xFF272236),
    colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.grey, brightness: Brightness.dark)
        .copyWith(secondary: Color(0xFF9E9E9E)));

class ThemeSettings extends BaseSharedPrefs {
  String _themeSettingKey = "THEME_SETTING";

  ThemeSetting currentThemeSetting = ThemeSetting.system;

  void init() async {
    int themeSettingInt = (await prefs).getInt(_themeSettingKey) ?? 0;

    if (themeSettingInt == 0) {
      currentThemeSetting = ThemeSetting.system;
    } else if (themeSettingInt == 1) {
      currentThemeSetting = ThemeSetting.light;
    } else {
      currentThemeSetting = ThemeSetting.dark;
    }
    notifyListeners();
  }

  void setTheme(ThemeSetting themeSetting) async {
    currentThemeSetting = themeSetting;
    (await prefs).setInt(_themeSettingKey, themeSetting.index);
    notifyListeners();
  }
}
