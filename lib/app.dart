import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "data/api_client.dart";
import "routes.dart";
import "state/app_settings.dart";
import "theme/semantic_colors.dart";

class RenqingLedgerApp extends ConsumerWidget {
  const RenqingLedgerApp({super.key});

  ThemeData _buildTheme({
    required Color brand,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;

    final semanticColors = {
      "income": receivedSemanticColor,
      "expense": sentSemanticColor,
      "neutral": isDark ? const Color(0xFFB8AEB2) : const Color(0xFF6B5A60),
      "surface": isDark ? const Color(0xFF140E11) : const Color(0xFFF7F4F6),
      "onSurface": isDark ? const Color(0xFFF2EAF0) : const Color(0xFF1B0A0F),
      "cardShadow": isDark ? const Color(0x33000000) : const Color(0x0A000000),
    };

    final colorScheme = ColorScheme.fromSeed(
      seedColor: brand,
      primary: brand,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: semanticColors["surface"],
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: semanticColors["surface"],
        foregroundColor: semanticColors["onSurface"],
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardTheme(
        color: isDark ? const Color(0xFF1E151A) : Colors.white,
        elevation: 0,
        shadowColor: semanticColors["cardShadow"],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E151A) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: brand,
            width: 2,
          ),
        ),
        labelStyle: TextStyle(
          color: semanticColors["neutral"],
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: semanticColors["neutral"]?.withValues(alpha: 0.7),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1A1216) : Colors.white,
        elevation: 8,
        shadowColor: semanticColors["cardShadow"],
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const brand = Color(0xFFD31145);
    final settings = ref.watch(appSettingsProvider);
    final themeMode = settings.themeMode;
    final fontScale = fontScaleFor(settings.fontSize);

    return MaterialApp(
      title: "人情账本",
      theme: _buildTheme(brand: brand, brightness: Brightness.light),
      darkTheme: _buildTheme(brand: brand, brightness: Brightness.dark),
      themeMode: toThemeMode(themeMode),
      initialRoute: ApiServices.client.isAuthenticated
          ? AppRoutes.records
          : AppRoutes.login,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(fontScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
