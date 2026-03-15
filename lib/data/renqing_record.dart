import "package:isar/isar.dart";

part "renqing_record.g.dart";

@collection
class RenqingRecord {
  Id id = Isar.autoIncrement;

  late String type; // 收礼 / 随礼
  late String name;
  late String relationship;
  String? relationshipNote;
  late String occasion;
  late int amount; // 收礼为正数，随礼为负数
  late DateTime date;
  String? note;
  DateTime createdAt = DateTime.now();
}
