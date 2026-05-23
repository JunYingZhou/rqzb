class RenqingRecord {
  RenqingRecord({
    this.id = 0,
    String? type,
    String? name,
    String? relationship,
    this.relationshipNote,
    String? occasion,
    this.amount = 0,
    DateTime? date,
    this.note,
    DateTime? createdAt,
  })  : type = type ?? "",
        name = name ?? "",
        relationship = relationship ?? "",
        occasion = occasion ?? "",
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  int id;
  String type;
  String name;
  String relationship;
  String? relationshipNote;
  String occasion;
  int amount;
  DateTime date;
  String? note;
  DateTime createdAt;

  factory RenqingRecord.fromJson(Map<String, dynamic> json) {
    return RenqingRecord(
      id: _readInt(json["id"]),
      type: (json["type"] as String?) ?? "",
      name: (json["name"] as String?) ?? "",
      relationship: (json["relationship"] as String?) ?? "",
      relationshipNote: json["relationshipNote"] as String?,
      occasion: (json["occasion"] as String?) ?? "",
      amount: _readInt(json["amount"]),
      date: _readDateTime(json["recordDate"] ?? json["date"]),
      note: json["note"] as String?,
      createdAt: _readDateTime(json["createdAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id > 0) "id": id,
      "type": type,
      "name": name,
      "relationship": relationship,
      "relationshipNote": relationshipNote,
      "occasion": occasion,
      "amount": amount,
      "recordDate": date.toUtc().toIso8601String(),
      "note": note,
      "createdAt": createdAt.toUtc().toIso8601String(),
    };
  }
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime _readDateTime(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
  }
  return DateTime.now();
}
