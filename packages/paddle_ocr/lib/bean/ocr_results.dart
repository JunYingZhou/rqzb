import 'package:json_annotation/json_annotation.dart';

import 'ocr_result.dart';

part 'ocr_results.g.dart';

@JsonSerializable()
class OcrResultInfo {
  List<OcrResult>? ocrResults;
  /**
   * ID_CARD,BANK_CARD,OTHER,EMPTY
   */
  String? ocr_type;

  OcrResultInfo({this.ocrResults = const [], this.ocr_type = 'OTHER'});

  factory OcrResultInfo.fromJson(Map<String, dynamic> json) =>
      _$OcrResultInfoFromJson(json);

  Map<String, dynamic> toJson() => _$OcrResultInfoToJson(this);
}
