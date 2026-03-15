import "package:flutter/material.dart";
import "routes.dart";

class RenqingLedgerApp extends StatelessWidget {
  const RenqingLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFFD31145);

    // Enhanced color palette with better semantic colors
    const semanticColors = {
      'income': Color(0xFF198754), // Green for income
      'expense': Color(0xFFB02A37), // Red for expense
      'neutral': Color(0xFF6B5A60), // Neutral text
      'surface': Color(0xFFF7F4F6), // Background
      'onSurface': Color(0xFF1B0A0F), // Primary text
      'cardShadow': Color(0x0A000000), // Subtle shadow
    };

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brand,
        primary: brand,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: semanticColors['surface'],
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
        backgroundColor: semanticColors['surface'],
        foregroundColor: semanticColors['onSurface'],
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shadowColor: semanticColors['cardShadow'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
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
          color: semanticColors['neutral'],
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: semanticColors['neutral']?.withValues(alpha: 0.7),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: semanticColors['cardShadow'],
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    return MaterialApp(
      title: "浜烘儏璐︽湰",
      theme: theme,
      initialRoute: AppRoutes.records,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
