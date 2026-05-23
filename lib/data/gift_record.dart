class GiftRecord {
  GiftRecord({
    this.id = 0,
    this.personId = 0,
    String? eventType,
    this.amount = 0,
    String? direction,
    this.eventDate,
    this.note,
    this.location,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : eventType = eventType ?? "",
        direction = direction ?? "",
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int id;
  int personId;
  String eventType;
  int amount;
  String direction;
  DateTime? eventDate;
  String? note;
  String? location;
  DateTime createdAt;
  DateTime updatedAt;

  factory GiftRecord.fromJson(Map<String, dynamic> json) {
    return GiftRecord(
      id: _readInt(json["id"]),
      personId: _readInt(json["personId"]),
      eventType: (json["eventType"] as String?) ?? "",
      amount: _readInt(json["amount"]),
      direction: (json["direction"] as String?) ?? "",
      eventDate: _readNullableDateTime(json["eventDate"]),
      note: json["note"] as String?,
      location: json["location"] as String?,
      createdAt: _readDateTime(json["createdAt"]),
      updatedAt: _readDateTime(json["updatedAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id > 0) "id": id,
      "personId": personId,
      "eventType": eventType,
      "amount": amount,
      "direction": direction,
      "eventDate": eventDate?.toUtc().toIso8601String(),
      "note": note,
      "location": location,
      "createdAt": createdAt.toUtc().toIso8601String(),
      "updatedAt": updatedAt.toUtc().toIso8601String(),
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
  return _readNullableDateTime(value) ?? DateTime.now();
}

DateTime? _readNullableDateTime(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toLocal();
  }
  return null;
}
