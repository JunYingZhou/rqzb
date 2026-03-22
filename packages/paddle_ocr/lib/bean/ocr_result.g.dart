// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OcrResult _$OcrResultFromJson(Map<String, dynamic> json) {
  return OcrResult(
    index: json['index'] as int?,
    name: json['name'] as String?,
    confidence: (json['confidence'] as num?)?.toDouble(),
    bounds: (json['bounds'] == null ? []:(json['bounds'] as List)
        .map(
            (e) => e == null ? null : Point.fromJson(e as Map<String, dynamic>))
        .toList()) as List<Point>,
  );
}

Map<String, dynamic> _$OcrResultToJson(OcrResult instance) => <String, dynamic>{
      'index': instance.index,
      'name': instance.name,
      'confidence': instance.confidence,
      'bounds': instance.bounds,
    };
