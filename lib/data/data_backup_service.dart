import "dart:convert";

import "gift_record.dart";
import "isar_db.dart";
import "person.dart";
import "renqing_record.dart";

class LedgerBackupPackage {
  const LedgerBackupPackage({
    required this.version,
    required this.exportedAt,
    required this.persons,
    required this.renqingRecords,
    required this.giftRecords,
  });

  final int version;
  final DateTime exportedAt;
  final List<LedgerBackupPerson> persons;
  final List<LedgerBackupRenqingRecord> renqingRecords;
  final List<LedgerBackupGiftRecord> giftRecords;

  Map<String, dynamic> toJson() {
    return {
      "version": version,
      "exportedAt": exportedAt.toIso8601String(),
      "persons": persons.map((item) => item.toJson()).toList(growable: false),
      "renqingRecords":
          renqingRecords.map((item) => item.toJson()).toList(growable: false),
      "giftRecords":
          giftRecords.map((item) => item.toJson()).toList(growable: false),
    };
  }

  factory LedgerBackupPackage.fromJson(Map<String, dynamic> json) {
    final persons = _readList(json["persons"])
        .map((item) => LedgerBackupPerson.fromJson(_readMap(item)))
        .toList(growable: false);
    final renqingRecords = _readList(json["renqingRecords"])
        .map((item) => LedgerBackupRenqingRecord.fromJson(_readMap(item)))
        .toList(growable: false);
    final giftRecords = _readList(json["giftRecords"])
        .map((item) => LedgerBackupGiftRecord.fromJson(_readMap(item)))
        .toList(growable: false);

    return LedgerBackupPackage(
      version: _readInt(json["version"], fallback: 1),
      exportedAt: _readDateTime(json["exportedAt"]) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      persons: persons,
      renqingRecords: renqingRecords,
      giftRecords: giftRecords,
    );
  }
}

class LedgerBackupPerson {
  const LedgerBackupPerson({
    required this.name,
    required this.relation,
    required this.phone,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String name;
  final String? relation;
  final String? phone;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory LedgerBackupPerson.fromPerson(Person person) {
    return LedgerBackupPerson(
      name: person.name,
      relation: person.relation,
      phone: person.phone,
      note: person.note,
      createdAt: person.createdAt,
      updatedAt: person.updatedAt,
    );
  }

  factory LedgerBackupPerson.fromJson(Map<String, dynamic> json) {
    return LedgerBackupPerson(
      name: _readString(json["name"]),
      relation: _readNullableString(json["relation"]),
      phone: _readNullableString(json["phone"]),
      note: _readNullableString(json["note"]),
      createdAt: _readDateTime(json["createdAt"]) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: _readDateTime(json["updatedAt"]) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "relation": relation,
      "phone": phone,
      "note": note,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  Person toPerson() {
    return Person()
      ..name = name.trim()
      ..relation = relation
      ..phone = phone
      ..note = note
      ..createdAt = createdAt
      ..updatedAt = updatedAt;
  }
}

class LedgerBackupRenqingRecord {
  const LedgerBackupRenqingRecord({
    required this.type,
    required this.name,
    required this.relationship,
    required this.relationshipNote,
    required this.occasion,
    required this.amount,
    required this.date,
    required this.note,
    required this.createdAt,
  });

  final String type;
  final String name;
  final String relationship;
  final String? relationshipNote;
  final String occasion;
  final int amount;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  factory LedgerBackupRenqingRecord.fromRecord(RenqingRecord record) {
    return LedgerBackupRenqingRecord(
      type: record.type,
      name: record.name,
      relationship: record.relationship,
      relationshipNote: record.relationshipNote,
      occasion: record.occasion,
      amount: record.amount,
      date: record.date,
      note: record.note,
      createdAt: record.createdAt,
    );
  }

  factory LedgerBackupRenqingRecord.fromJson(Map<String, dynamic> json) {
    return LedgerBackupRenqingRecord(
      type: _readString(json["type"]),
      name: _readString(json["name"]),
      relationship: _readString(json["relationship"]),
      relationshipNote: _readNullableString(json["relationshipNote"]),
      occasion: _readString(json["occasion"]),
      amount: _readInt(json["amount"]),
      date:
          _readDateTime(json["date"]) ?? DateTime.fromMillisecondsSinceEpoch(0),
      note: _readNullableString(json["note"]),
      createdAt: _readDateTime(json["createdAt"]) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "name": name,
      "relationship": relationship,
      "relationshipNote": relationshipNote,
      "occasion": occasion,
      "amount": amount,
      "date": date.toIso8601String(),
      "note": note,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  RenqingRecord toRecord() {
    return RenqingRecord()
      ..type = type
      ..name = name.trim()
      ..relationship = relationship
      ..relationshipNote = relationshipNote
      ..occasion = occasion
      ..amount = amount
      ..date = date
      ..note = note
      ..createdAt = createdAt;
  }
}

class LedgerBackupGiftRecord {
  const LedgerBackupGiftRecord({
    required this.personName,
    required this.eventType,
    required this.amount,
    required this.direction,
    required this.eventDate,
    required this.note,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  final String personName;
  final String eventType;
  final int amount;
  final String direction;
  final DateTime? eventDate;
  final String? note;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory LedgerBackupGiftRecord.fromRecord(
    GiftRecord record, {
    required String personName,
  }) {
    return LedgerBackupGiftRecord(
      personName: personName,
      eventType: record.eventType,
      amount: record.amount,
      direction: record.direction,
      eventDate: record.eventDate,
      note: record.note,
      location: record.location,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }

  factory LedgerBackupGiftRecord.fromJson(Map<String, dynamic> json) {
    return LedgerBackupGiftRecord(
      personName: _readString(json["personName"]),
      eventType: _readString(json["eventType"]),
      amount: _readInt(json["amount"]),
      direction: _readString(json["direction"]),
      eventDate: _readDateTime(json["eventDate"]),
      note: _readNullableString(json["note"]),
      location: _readNullableString(json["location"]),
      createdAt: _readDateTime(json["createdAt"]) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: _readDateTime(json["updatedAt"]) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "personName": personName,
      "eventType": eventType,
      "amount": amount,
      "direction": direction,
      "eventDate": eventDate?.toIso8601String(),
      "note": note,
      "location": location,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  GiftRecord toRecord({required int personId}) {
    return GiftRecord()
      ..personId = personId
      ..eventType = eventType
      ..amount = amount
      ..direction = direction
      ..eventDate = eventDate
      ..note = note
      ..location = location
      ..createdAt = createdAt
      ..updatedAt = updatedAt;
  }
}

class LedgerBackupImportReport {
  const LedgerBackupImportReport({
    required this.importedPersons,
    required this.updatedPersons,
    required this.importedRenqingRecords,
    required this.skippedRenqingRecords,
    required this.importedGiftRecords,
    required this.skippedGiftRecords,
  });

  final int importedPersons;
  final int updatedPersons;
  final int importedRenqingRecords;
  final int skippedRenqingRecords;
  final int importedGiftRecords;
  final int skippedGiftRecords;

  int get importedTotal =>
      importedPersons + importedRenqingRecords + importedGiftRecords;
}

class DataBackupService {
  static const int formatVersion = 1;

  static Future<String> exportJsonString() async {
    final payload = await _capture();
    return const JsonEncoder.withIndent("  ").convert(payload.toJson());
  }

  static Future<LedgerBackupImportReport> importJsonString(
      String source) async {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException("Invalid backup format.");
    }

    final payload = LedgerBackupPackage.fromJson(decoded);
    return _importPayload(payload);
  }

  static Future<LedgerBackupPackage> _capture() async {
    final persons = await PersonRepository.loadAll();
    persons.sort((left, right) => left.name.compareTo(right.name));

    final renqingRecords = await RecordRepository.loadAll();
    renqingRecords.sort(_compareRenqingRecord);

    final giftRecords = await GiftRecordRepository.loadAll();
    giftRecords.sort(_compareGiftRecord);

    final personNameById = {
      for (final person in persons) person.id: person.name,
    };

    return LedgerBackupPackage(
      version: formatVersion,
      exportedAt: DateTime.now(),
      persons:
          persons.map(LedgerBackupPerson.fromPerson).toList(growable: false),
      renqingRecords: renqingRecords
          .map(LedgerBackupRenqingRecord.fromRecord)
          .toList(growable: false),
      giftRecords: giftRecords.map((record) {
        final personName = personNameById[record.personId] ?? "";
        return LedgerBackupGiftRecord.fromRecord(
          record,
          personName: personName,
        );
      }).toList(growable: false),
    );
  }

  static Future<LedgerBackupImportReport> _importPayload(
    LedgerBackupPackage payload,
  ) async {
    final existingPersons = await PersonRepository.loadAll();
    final personsByName = {
      for (final person in existingPersons) _normalizeName(person.name): person,
    };

    final personWrites = <Person>[];
    final backupNames = <String>{};
    var importedPersons = 0;
    var updatedPersons = 0;

    for (final backupPerson in payload.persons) {
      final normalizedName = _normalizeName(backupPerson.name);
      if (normalizedName.isEmpty) {
        continue;
      }
      backupNames.add(normalizedName);

      final existingPerson = personsByName[normalizedName];
      if (existingPerson == null) {
        personWrites.add(backupPerson.toPerson());
        importedPersons++;
        continue;
      }

      if (_mergePerson(existingPerson, backupPerson)) {
        personWrites.add(existingPerson);
        updatedPersons++;
      }
    }

    if (personWrites.isNotEmpty) {
      await IsarDb.instance.writeTxn(() async {
        await IsarDb.instance.persons.putAll(personWrites);
      });
    }

    final resolvedPersonsByName = <String, Person>{};
    for (final name in backupNames) {
      final person = await PersonRepository.findByName(name);
      if (person != null) {
        resolvedPersonsByName[name] = person;
      }
    }

    final existingRenqingRecords = await RecordRepository.loadAll();
    final renqingKeys = existingRenqingRecords.map(_renqingSignature).toSet();
    final renqingWrites = <RenqingRecord>[];
    var importedRenqingRecords = 0;
    var skippedRenqingRecords = 0;

    for (final backupRecord in payload.renqingRecords) {
      final record = backupRecord.toRecord();
      final normalizedKey = _renqingSignature(record);
      if (!renqingKeys.add(normalizedKey)) {
        skippedRenqingRecords++;
        continue;
      }
      renqingWrites.add(record);
      importedRenqingRecords++;
    }

    if (renqingWrites.isNotEmpty) {
      await IsarDb.instance.writeTxn(() async {
        await IsarDb.instance.renqingRecords.putAll(renqingWrites);
      });
    }

    final existingGiftRecords = await GiftRecordRepository.loadAll();
    final giftKeys = existingGiftRecords.map(_giftSignature).toSet();
    final giftWrites = <GiftRecord>[];
    var importedGiftRecords = 0;
    var skippedGiftRecords = 0;

    for (final backupRecord in payload.giftRecords) {
      final personName = _normalizeName(backupRecord.personName);
      final person = resolvedPersonsByName[personName];
      if (person == null) {
        skippedGiftRecords++;
        continue;
      }

      final record = backupRecord.toRecord(personId: person.id);
      final normalizedKey = _giftSignature(record);
      if (!giftKeys.add(normalizedKey)) {
        skippedGiftRecords++;
        continue;
      }
      giftWrites.add(record);
      importedGiftRecords++;
    }

    if (giftWrites.isNotEmpty) {
      await IsarDb.instance.writeTxn(() async {
        await IsarDb.instance.giftRecords.putAll(giftWrites);
      });
    }

    return LedgerBackupImportReport(
      importedPersons: importedPersons,
      updatedPersons: updatedPersons,
      importedRenqingRecords: importedRenqingRecords,
      skippedRenqingRecords: skippedRenqingRecords,
      importedGiftRecords: importedGiftRecords,
      skippedGiftRecords: skippedGiftRecords,
    );
  }
}

bool _mergePerson(Person target, LedgerBackupPerson source) {
  var changed = false;

  final normalizedName = _normalizeName(source.name);
  if (normalizedName.isNotEmpty && target.name != normalizedName) {
    target.name = normalizedName;
    changed = true;
  }

  final nextRelation = _normalizeOptionalString(source.relation);
  if (nextRelation != null && target.relation != nextRelation) {
    target.relation = nextRelation;
    changed = true;
  }

  final nextPhone = _normalizeOptionalString(source.phone);
  if (nextPhone != null && target.phone != nextPhone) {
    target.phone = nextPhone;
    changed = true;
  }

  final nextNote = _normalizeOptionalString(source.note);
  if (nextNote != null && target.note != nextNote) {
    target.note = nextNote;
    changed = true;
  }

  if (changed) {
    target.updatedAt = source.updatedAt;
  }

  return changed;
}

String _renqingSignature(RenqingRecord record) {
  return [
    record.type.trim(),
    record.name.trim(),
    record.relationship.trim(),
    record.relationshipNote?.trim() ?? "",
    record.occasion.trim(),
    record.amount.toString(),
    record.date.toIso8601String(),
    record.note?.trim() ?? "",
  ].join("|");
}

String _giftSignature(GiftRecord record) {
  return [
    record.personId.toString(),
    record.eventType.trim(),
    record.amount.toString(),
    record.direction.trim(),
    record.eventDate?.toIso8601String() ?? "",
    record.note?.trim() ?? "",
    record.location?.trim() ?? "",
  ].join("|");
}

int _compareRenqingRecord(RenqingRecord left, RenqingRecord right) {
  final dateCompare = left.date.compareTo(right.date);
  if (dateCompare != 0) return dateCompare;
  return left.createdAt.compareTo(right.createdAt);
}

int _compareGiftRecord(GiftRecord left, GiftRecord right) {
  final dateCompare = (left.eventDate ?? left.createdAt)
      .compareTo(right.eventDate ?? right.createdAt);
  if (dateCompare != 0) return dateCompare;
  return left.createdAt.compareTo(right.createdAt);
}

String _normalizeName(String value) => value.trim();

String? _normalizeOptionalString(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return normalized;
}

Map<String, dynamic> _readMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return const <String, dynamic>{};
}

List<dynamic> _readList(dynamic value) {
  if (value is List<dynamic>) return value;
  if (value is List) return value.cast<dynamic>();
  return const <dynamic>[];
}

String _readString(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    throw const FormatException("Invalid backup data.");
  }
  return text;
}

String? _readNullableString(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return text;
}

int _readInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? "") ?? fallback;
}

DateTime? _readDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
