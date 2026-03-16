import "package:isar/isar.dart";
import "package:path_provider/path_provider.dart";

import "gift_record.dart";
import "person.dart";
import "renqing_record.dart";

class IsarDb {
  static Isar? _instance;

  static Isar get instance {
    final value = _instance;
    if (value == null) {
      throw StateError("Isar has not been initialized.");
    }
    return value;
  }

  static Future<void> init() async {
    if (_instance != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [RenqingRecordSchema, PersonSchema, GiftRecordSchema],
      directory: dir.path,
    );
  }
}

class RecordRepository {
  static Stream<List<RenqingRecord>> watchAll() {
    return IsarDb.instance.renqingRecords
        .where()
        .sortByDateDesc()
        .watch(fireImmediately: true);
  }

  static Future<void> add(RenqingRecord record) async {
    await IsarDb.instance.writeTxn(() async {
      await IsarDb.instance.renqingRecords.put(record);
    });
  }
}

class PersonRepository {
  static Stream<List<Person>> watchAll() {
    return IsarDb.instance.persons.where().watch(fireImmediately: true);
  }

  static Future<Person?> findByName(String name) {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      return Future.value(null);
    }

    return IsarDb.instance.persons
        .filter()
        .nameEqualTo(normalizedName)
        .findFirst();
  }

  static Future<void> add(Person person) async {
    person.updatedAt = DateTime.now();
    await IsarDb.instance.writeTxn(() async {
      await IsarDb.instance.persons.put(person);
    });
  }

  static Future<void> deleteByIds(List<Id> ids) async {
    if (ids.isEmpty) return;
    await IsarDb.instance.writeTxn(() async {
      await IsarDb.instance.persons.deleteAll(ids);
    });
  }
}
