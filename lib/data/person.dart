import "package:isar/isar.dart";

part "person.g.dart";

@collection
class Person {
  Id id = Isar.autoIncrement;

  late String name; // 姓名
  String? relation; // 关系：同事/朋友/亲戚
  String? phone;
  String? note;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
