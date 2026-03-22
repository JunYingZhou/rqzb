import 'package:json_annotation/json_annotation.dart';

part 'point.g.dart';

@JsonSerializable()
class Point {
  double? x;
  double? y;

  Point({this.x = 0.0, this.y = 0.0});

  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);

  Map<String, dynamic> toJson() => _$PointToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
