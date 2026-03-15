import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";
import "app.dart";
import "data/isar_db.dart";
import "state/app_settings.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarDb.init();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const RenqingLedgerApp(),
    ),
  );
}
