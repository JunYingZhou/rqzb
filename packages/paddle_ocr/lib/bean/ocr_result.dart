import 'package:json_annotation/json_annotation.dart';

import 'point.dart';

part 'ocr_result.g.dart';

@JsonSerializable()
class OcrResult {
  int? index;
  String? name;
  double? confidence;
  List<Point>? bounds;

  OcrResult({
    this.index = -1,
    this.name = '',
    this.confidence = 0.0,
    this.bounds = const [],
  });

  factory OcrResult.fromJson(Map<String, dynamic> json) =>
      _$OcrResultFromJson(json);

  Map<String, dynamic> toJson() => _$OcrResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
