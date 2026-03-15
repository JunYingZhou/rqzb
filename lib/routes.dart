import "package:flutter/material.dart";
import "pages/add_record_page.dart";
import "pages/profile_page.dart";
import "pages/record_page.dart";

class AppRoutes {
  static const records = "/records";
  static const profile = "/profile";
  static const addRecord = "/add-record";

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case records:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RecordPage(),
        );
      case profile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfilePage(),
        );
      case addRecord:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddRecordPage(),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RecordPage(),
        );
    }
  }
}
