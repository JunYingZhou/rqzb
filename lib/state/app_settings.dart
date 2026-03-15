import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

enum AppThemeMode { light, dark }

enum AppFontSize { small, medium, large }

final appThemeModeProvider =
    StateProvider<AppThemeMode>((ref) => AppThemeMode.light);

final appFontSizeProvider =
    StateProvider<AppFontSize>((ref) => AppFontSize.medium);

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

