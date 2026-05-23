class Person {
  Person({
    this.id = 0,
    String? name,
    this.relation,
    this.phone,
    this.note,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : name = name ?? "",
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int id;
  String name;
  String? relation;
  String? phone;
  String? note;
  DateTime createdAt;
  DateTime updatedAt;

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: _readInt(json["id"]),
      name: (json["name"] as String?) ?? "",
      relation: json["relation"] as String?,
      phone: json["phone"] as String?,
      note: json["note"] as String?,
      createdAt: _readDateTime(json["createdAt"]),
      updatedAt: _readDateTime(json["updatedAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id > 0) "id": id,
      "name": name,
      "relation": relation,
      "phone": phone,
      "note": note,
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
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
  }
  return DateTime.now();
}
