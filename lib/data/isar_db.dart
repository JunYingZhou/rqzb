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

  static Stream<List<RenqingRecord>> watchByName(String name) {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      return Stream.value(const <RenqingRecord>[]);
    }

    return IsarDb.instance.renqingRecords
        .filter()
        .nameEqualTo(normalizedName)
        .sortByDateDesc()
        .watch(fireImmediately: true);
  }

  static Future<void> add(RenqingRecord record) async {
    await IsarDb.instance.writeTxn(() async {
      await IsarDb.instance.renqingRecords.put(record);
    });
  }

  static Future<bool> updateAmount({
    required Id id,
    required int amount,
  }) async {
    final record = await IsarDb.instance.renqingRecords.get(id);
    if (record == null) return false;

    record.amount = amount;
    await IsarDb.instance.writeTxn(() async {
      await IsarDb.instance.renqingRecords.put(record);
    });
    return true;
  }
}

class ContactDeletePreview {
  const ContactDeletePreview({
    required this.contactCount,
    required this.renqingRecordCount,
    required this.giftRecordCount,
  });

  final int contactCount;
  final int renqingRecordCount;
  final int giftRecordCount;

  int get totalRelatedRecordCount => renqingRecordCount + giftRecordCount;
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

  static Future<ContactDeletePreview> previewDeleteByIds(List<Id> ids) async {
    final persons = await _loadPersonsByIds(ids);
    if (persons.isEmpty) {
      return const ContactDeletePreview(
        contactCount: 0,
        renqingRecordCount: 0,
        giftRecordCount: 0,
      );
    }

    final renqingRecordIds = await _findRenqingRecordIdsByPersons(persons);
    final giftRecordIds = await _findGiftRecordIdsByPersons(persons);

    return ContactDeletePreview(
      contactCount: persons.length,
      renqingRecordCount: renqingRecordIds.length,
      giftRecordCount: giftRecordIds.length,
    );
  }

  static Future<void> deleteByIds(List<Id> ids) async {
    final persons = await _loadPersonsByIds(ids);
    if (persons.isEmpty) return;

    final personIds =
        persons.map((person) => person.id).toList(growable: false);
    final renqingRecordIds = await _findRenqingRecordIdsByPersons(persons);
    final giftRecordIds = await _findGiftRecordIdsByPersons(persons);

    await IsarDb.instance.writeTxn(() async {
      if (renqingRecordIds.isNotEmpty) {
        await IsarDb.instance.renqingRecords.deleteAll(renqingRecordIds);
      }
      if (giftRecordIds.isNotEmpty) {
        await IsarDb.instance.giftRecords.deleteAll(giftRecordIds);
      }
      await IsarDb.instance.persons.deleteAll(personIds);
    });
  }

  static Future<List<Person>> _loadPersonsByIds(List<Id> ids) async {
    final persons = <Person>[];

    for (final id in ids.toSet()) {
      final person = await IsarDb.instance.persons.get(id);
      if (person != null) {
        persons.add(person);
      }
    }

    return persons;
  }

  static Future<List<Id>> _findRenqingRecordIdsByPersons(
    List<Person> persons,
  ) async {
    // Existing renqing records are associated by contact name.
    final names = persons
        .map((person) => person.name.trim())
        .where((name) => name.isNotEmpty)
        .toSet();
    final recordIds = <Id>{};

    for (final name in names) {
      final ids = await IsarDb.instance.renqingRecords
          .filter()
          .nameEqualTo(name)
          .idProperty()
          .findAll();
      recordIds.addAll(ids);
    }

    return recordIds.toList(growable: false);
  }

  static Future<List<Id>> _findGiftRecordIdsByPersons(
    List<Person> persons,
  ) async {
    final personIds = persons.map((person) => person.id).toSet();
    final recordIds = <Id>{};

    for (final personId in personIds) {
      final ids = await IsarDb.instance.giftRecords
          .filter()
          .personIdEqualTo(personId)
          .idProperty()
          .findAll();
      recordIds.addAll(ids);
    }

    return recordIds.toList(growable: false);
  }
}
