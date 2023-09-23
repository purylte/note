import 'package:flutter/material.dart';
import 'package:notes/src/db.dart';

const String _themeModeSetting = 'themeMode';

class SettingsService {
  Future<ThemeMode> themeMode() async {
    final Db db = Db();
    final setting = await db.getSetting(_themeModeSetting);
    if (setting == null) {
      return ThemeMode.system;
    }
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == setting.value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    final Db db = Db();
    await db.insertOrUpdateSetting(
        setting: _themeModeSetting, value: theme.toString());
  }
}
