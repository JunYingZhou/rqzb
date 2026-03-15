import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

enum AppThemeMode { light, dark }

enum AppFontSize { small, medium, large }

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.fontSize,
  });

  final AppThemeMode themeMode;
  final AppFontSize fontSize;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    AppFontSize? fontSize,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

const _themeKey = "settings_theme_mode";
const _fontKey = "settings_font_size";

final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError("sharedPrefsProvider must be overridden"),
);

final appSettingsProvider =
    StateNotifierProvider<AppSettingsController, AppSettings>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return AppSettingsController(prefs);
});

class AppSettingsController extends StateNotifier<AppSettings> {
  AppSettingsController(this._prefs)
      : super(
          AppSettings(
            themeMode: _readTheme(_prefs),
            fontSize: _readFont(_prefs),
          ),
        );

  final SharedPreferences _prefs;

  void toggleTheme() {
    final next = state.themeMode == AppThemeMode.light
        ? AppThemeMode.dark
        : AppThemeMode.light;
    state = state.copyWith(themeMode: next);
    _prefs.setString(_themeKey, next.name);
  }

  void cycleFontSize() {
    final next = switch (state.fontSize) {
      AppFontSize.small => AppFontSize.medium,
      AppFontSize.medium => AppFontSize.large,
      AppFontSize.large => AppFontSize.small,
    };
    state = state.copyWith(fontSize: next);
    _prefs.setString(_fontKey, next.name);
  }
}

AppThemeMode _readTheme(SharedPreferences prefs) {
  final raw = prefs.getString(_themeKey);
  return AppThemeMode.values.firstWhere(
    (mode) => mode.name == raw,
    orElse: () => AppThemeMode.light,
  );
}

AppFontSize _readFont(SharedPreferences prefs) {
  final raw = prefs.getString(_fontKey);
  return AppFontSize.values.firstWhere(
    (size) => size.name == raw,
    orElse: () => AppFontSize.medium,
  );
}

ThemeMode toThemeMode(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.light:
      return ThemeMode.light;
  }
}

double fontScaleFor(AppFontSize size) {
  switch (size) {
    case AppFontSize.small:
      return 0.9;
    case AppFontSize.medium:
      return 1.0;
    case AppFontSize.large:
      return 1.1;
  }
}

String labelForFontSize(AppFontSize size) {
  switch (size) {
    case AppFontSize.small:
      return "小";
    case AppFontSize.medium:
      return "中";
    case AppFontSize.large:
      return "大";
  }
}

