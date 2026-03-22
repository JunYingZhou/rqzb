// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_results.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OcrResultInfo _$OcrResultInfoFromJson(Map<String, dynamic> json) {
  return OcrResultInfo(
    ocrResults: (json['ocrResults'] == null ? []:(json['ocrResults'] as List)
        .map((e) =>
            e == null ? null : OcrResult.fromJson(e as Map<String, dynamic>))
        .toList()) as List<OcrResult>,
    ocr_type: json['ocr_type'] as String?,
  );
}

Map<String, dynamic> _$OcrResultInfoToJson(OcrResultInfo instance) =>
    <String, dynamic>{
      'ocrResults': instance.ocrResults,
      'ocr_type': instance.ocr_type,
    };
