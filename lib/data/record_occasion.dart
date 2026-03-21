import "package:flutter/material.dart";

enum RecordOccasion {
  wedding,
  fullMoon,
  housewarming,
  birthdayBanquet,
  schoolEntrance,
  opening,
  funeral,
}

extension RecordOccasionX on RecordOccasion {
  String get label {
    switch (this) {
      case RecordOccasion.wedding:
        return "婚礼";
      case RecordOccasion.fullMoon:
        return "满月";
      case RecordOccasion.housewarming:
        return "乔迁";
      case RecordOccasion.birthdayBanquet:
        return "寿宴";
      case RecordOccasion.schoolEntrance:
        return "升学";
      case RecordOccasion.opening:
        return "开业";
      case RecordOccasion.funeral:
        return "白事";
    }
  }

  IconData get icon {
    switch (this) {
      case RecordOccasion.wedding:
        return Icons.favorite;
      case RecordOccasion.fullMoon:
        return Icons.child_care;
      case RecordOccasion.housewarming:
        return Icons.home;
      case RecordOccasion.birthdayBanquet:
        return Icons.cake;
      case RecordOccasion.schoolEntrance:
        return Icons.school;
      case RecordOccasion.opening:
        return Icons.business;
      case RecordOccasion.funeral:
        return Icons.church;
    }
  }
}

RecordOccasion? recordOccasionFromLabel(String label) {
  for (final occasion in RecordOccasion.values) {
    if (occasion.label == label) {
      return occasion;
    }
  }
  return null;
}
