import "dart:async";

import "api_client.dart";
import "gift_record.dart";
import "person.dart";
import "renqing_record.dart";

class IsarDb {
  static void init() {}
}

class _RepositoryRefresh {
  static final records = StreamController<void>.broadcast();
  static final persons = StreamController<void>.broadcast();
  static final giftRecords = StreamController<void>.broadcast();

  static void refreshRecords() => records.add(null);
  static void refreshPersons() => persons.add(null);
  static void refreshGiftRecords() => giftRecords.add(null);
  static void refreshAll() {
    refreshRecords();
    refreshPersons();
    refreshGiftRecords();
  }
}

class RecordRepository {
  static Stream<List<RenqingRecord>> watchAll() async* {
    yield await loadAll();
    yield* _RepositoryRefresh.records.stream.asyncMap((_) => loadAll());
  }

  static Future<List<RenqingRecord>> loadAll() async {
    final records = await ApiServices.client.getList(
      "/api/renqing/records/list",
      RenqingRecord.fromJson,
    );
    records.sort((left, right) => right.date.compareTo(left.date));
    return records;
  }

  static Stream<List<RenqingRecord>> watchByName(String name) async* {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      yield const <RenqingRecord>[];
      return;
    }

    yield await loadByName(normalizedName);
    yield* _RepositoryRefresh.records.stream.asyncMap(
      (_) => loadByName(normalizedName),
    );
  }

  static Future<List<RenqingRecord>> loadByName(String name) async {
    final records = await ApiServices.client.getList(
      "/api/renqing/records/name/${Uri.encodeComponent(name)}",
      RenqingRecord.fromJson,
    );
    records.sort((left, right) => right.date.compareTo(left.date));
    return records;
  }

  static Future<RenqingRecord> add(RenqingRecord record) async {
    final created = await ApiServices.client.post(
      "/api/renqing/records",
      body: record.toJson(),
      fromJson: RenqingRecord.fromJson,
    );
    _RepositoryRefresh.refreshRecords();
    return created;
  }

  static Future<void> addAll(List<RenqingRecord> records) async {
    for (final record in records) {
      await add(record);
    }
  }

  static Future<bool> updateAmount({
    required int id,
    required int amount,
  }) async {
    if (id <= 0) return false;

    try {
      final record = await ApiServices.client.getObject(
        "/api/renqing/records/$id",
        RenqingRecord.fromJson,
      );
      record.amount = amount;
      await ApiServices.client.put(
        "/api/renqing/records/$id",
        body: record.toJson(),
        fromJson: RenqingRecord.fromJson,
      );
      _RepositoryRefresh.refreshRecords();
      return true;
    } on ApiException {
      return false;
    }
  }

  static Future<void> deleteByIds(List<int> ids) async {
    for (final id in ids.where((id) => id > 0).toSet()) {
      await ApiServices.client.delete("/api/renqing/records/$id");
    }
    _RepositoryRefresh.refreshRecords();
  }
}

class GiftRecordRepository {
  static Future<List<GiftRecord>> loadAll() async {
    return ApiServices.client.getList(
      "/api/renqing/gift-records/list",
      GiftRecord.fromJson,
    );
  }

  static Future<GiftRecord> add(GiftRecord record) async {
    final created = await ApiServices.client.post(
      "/api/renqing/gift-records",
      body: record.toJson(),
      fromJson: GiftRecord.fromJson,
    );
    _RepositoryRefresh.refreshGiftRecords();
    return created;
  }

  static Future<void> addAll(List<GiftRecord> records) async {
    for (final record in records) {
      await add(record);
    }
  }

  static Future<void> deleteByIds(List<int> ids) async {
    for (final id in ids.where((id) => id > 0).toSet()) {
      await ApiServices.client.delete("/api/renqing/gift-records/$id");
    }
    _RepositoryRefresh.refreshGiftRecords();
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
  static Stream<List<Person>> watchAll() async* {
    yield await loadAll();
    yield* _RepositoryRefresh.persons.stream.asyncMap((_) => loadAll());
  }

  static Future<List<Person>> loadAll() async {
    return ApiServices.client.getList(
      "/api/renqing/persons/list",
      Person.fromJson,
    );
  }

  static Future<Person?> findByName(String name) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) return null;

    final persons = await ApiServices.client.getList(
      "/api/renqing/persons/name/${Uri.encodeComponent(normalizedName)}",
      Person.fromJson,
    );
    for (final person in persons) {
      if (person.name.trim() == normalizedName) {
        return person;
      }
    }
    return persons.isEmpty ? null : persons.first;
  }

  static Future<Person> add(Person person) async {
    person.updatedAt = DateTime.now();
    final created = await ApiServices.client.post(
      "/api/renqing/persons",
      body: person.toJson(),
      fromJson: Person.fromJson,
    );
    _RepositoryRefresh.refreshPersons();
    return created;
  }

  static Future<Person> update(Person person) async {
    person.updatedAt = DateTime.now();
    final updated = await ApiServices.client.put(
      "/api/renqing/persons/${person.id}",
      body: person.toJson(),
      fromJson: Person.fromJson,
    );
    _RepositoryRefresh.refreshPersons();
    return updated;
  }

  static Future<void> ensureNames(Iterable<String> names) async {
    final normalizedNames = names
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet();
    if (normalizedNames.isEmpty) return;

    var didCreate = false;
    final createdAt = DateTime.now();
    for (final name in normalizedNames) {
      final exists = await findByName(name);
      if (exists != null) continue;

      await add(
        Person(
          name: name,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
      didCreate = true;
    }

    if (didCreate) {
      _RepositoryRefresh.refreshPersons();
    }
  }

  static Future<ContactDeletePreview> previewDeleteByIds(List<int> ids) async {
    final persons = await _loadPersonsByIds(ids);
    if (persons.isEmpty) {
      return const ContactDeletePreview(
        contactCount: 0,
        renqingRecordCount: 0,
        giftRecordCount: 0,
      );
    }

    final records = await RecordRepository.loadAll();
    final gifts = await GiftRecordRepository.loadAll();
    final names = persons.map((person) => person.name.trim()).toSet();
    final personIds = persons.map((person) => person.id).toSet();

    return ContactDeletePreview(
      contactCount: persons.length,
      renqingRecordCount: records
          .where((record) => names.contains(record.name.trim()))
          .length,
      giftRecordCount:
          gifts.where((record) => personIds.contains(record.personId)).length,
    );
  }

  static Future<void> deleteByIds(List<int> ids) async {
    final persons = await _loadPersonsByIds(ids);
    if (persons.isEmpty) return;

    final records = await RecordRepository.loadAll();
    final gifts = await GiftRecordRepository.loadAll();
    final names = persons.map((person) => person.name.trim()).toSet();
    final personIds = persons.map((person) => person.id).toSet();

    await RecordRepository.deleteByIds(
      records
          .where((record) => names.contains(record.name.trim()))
          .map((record) => record.id)
          .toList(growable: false),
    );
    await GiftRecordRepository.deleteByIds(
      gifts
          .where((record) => personIds.contains(record.personId))
          .map((record) => record.id)
          .toList(growable: false),
    );

    for (final id in personIds) {
      await ApiServices.client.delete("/api/renqing/persons/$id");
    }
    _RepositoryRefresh.refreshAll();
  }

  static Future<List<Person>> _loadPersonsByIds(List<int> ids) async {
    final persons = <Person>[];
    for (final id in ids.where((id) => id > 0).toSet()) {
      persons.add(
        await ApiServices.client.getObject(
          "/api/renqing/persons/$id",
          Person.fromJson,
        ),
      );
    }
    return persons;
  }
}
