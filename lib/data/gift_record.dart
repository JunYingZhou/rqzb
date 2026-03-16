import "package:isar/isar.dart";

part "gift_record.g.dart";

@collection
class GiftRecord {
  Id id = Isar.autoIncrement;

  late int personId; // 关联 Person
  late String eventType; // 婚礼 / 满月 / 乔迁 / 葬礼 / 生日
  late int amount; // 金额
  late String direction; // give / receive
  DateTime? eventDate; // 事件日期
  String? note; // 备注
  String? location; // 城市/地点
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
