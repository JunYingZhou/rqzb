import "package:flutter/material.dart";
import "app.dart";
import "data/isar_db.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarDb.init();
  runApp(const RenqingLedgerApp());
}
