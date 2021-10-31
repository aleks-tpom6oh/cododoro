import 'package:cododoro/storage/ThemeSettings.dart';
import 'package:flutter/material.dart';

class ThemeSettingsCategory extends StatelessWidget {
  const ThemeSettingsCategory({Key? key, required this.themeSettings})
      : super(key: key);

  final ThemeSettings themeSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Looks",
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("theme"),
            SizedBox(width: 16),
            DropdownButton<String>(
              value:
                  themeSettings.currentThemeSetting.toString().split('.').last,
              items: ThemeSetting.values
                  .map((themeSettingType) =>
                      themeSettingType.toString().split('.').last)
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              onChanged: (newThemeSettingTypeString) {
                if (newThemeSettingTypeString != null) {
                  final newThemeSettingType = ThemeSetting.values.firstWhere(
                      (element) => element
                          .toString()
                          .contains(newThemeSettingTypeString));

                  themeSettings.setTheme(newThemeSettingType);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
