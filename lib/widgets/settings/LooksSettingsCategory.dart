import 'package:cododoro/data_layer/storage/ThemeSettings.dart';
import 'package:cododoro/data_layer/storage/Settings.dart';
import 'package:flutter/material.dart';

class LooksSettingsCategory extends StatefulWidget {
  const LooksSettingsCategory({Key? key, required this.themeSettings, required this.settings,})
      : super(key: key);

  final ThemeSettings themeSettings;
  final Settings settings;

  @override
  State<LooksSettingsCategory> createState() => _LooksSettingsCategoryState();
}

class _LooksSettingsCategoryState extends State<LooksSettingsCategory> {
  bool? showCuteCatsEnabled;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.greenAccent;
      }

      return Colors.grey;
    }

    showCuteCatsEnabled = this.widget.settings.showCuteCats;

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
                  widget.themeSettings.currentThemeSetting.toString().split('.').last,
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

                  widget.themeSettings.setTheme(newThemeSettingType);
                }
              },
            ),
            SizedBox(width: 48),
            Checkbox(
              checkColor: Colors.white,
              fillColor: MaterialStateProperty.resolveWith(getColor),
              value: showCuteCatsEnabled,
              onChanged: (bool? value) {
                if (value != null) {
                  widget.settings.setShowCuteCats(value);
                  setState(() {
                    showCuteCatsEnabled = value;
                  });
                }
              },
            ),
            Text("Show cute cats"),
          ],
        ),
      ],
    );
  }
}
