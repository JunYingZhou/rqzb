// ignore_for_file: non_constant_identifier_names

import "dart:convert";

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

import "bean/ocr_results.dart";

class PaddleOcr {
  static const MethodChannel _channel = MethodChannel("paddle_ocr");

  static Future<String?> get platformVersion async {
    final version = await _channel.invokeMethod<String>("getPlatformVersion");
    return version;
  }

  static Future<Map<String, dynamic>> ocrFromImage(
    String imagePath, {
    bool isRotate = false,
    bool forwardRotation = true,
    double degree = 90.0,
    String? ocr_type,
    bool isPrint = false,
  }) async {
    try {
      final ocrStr = await _channel.invokeMethod<String>(
        "ocrFromImage",
        {"imagePath": imagePath},
      );
      final parsedResult = _processOcrResult(
        ocrStr ?? "[]",
        ocr_type: ocr_type,
        isPrint: isPrint,
      );

      return {
        "success": true,
        "code": "0",
        "message": "识别成功",
        "ocrResult": parsedResult ??
            OcrResultInfo(ocrResults: const [], ocr_type: "EMPTY"),
      };
    } on PlatformException catch (error) {
      return {
        "success": false,
        "code": error.code,
        "message": error.message,
        "ocrResult": null,
      };
    } catch (error) {
      return {
        "success": false,
        "code": "-999",
        "message": error.toString(),
        "ocrResult": null,
      };
    }
  }

  static OcrResultInfo? _processOcrResult(
    String ocrStr, {
    String? ocr_type,
    bool isPrint = false,
  }) {
    try {
      final normalizedText = ocrStr.replaceAll(RegExp(r"[\\r\\n]{1,2}"), "");
      final ocrResultInfo = OcrResultInfo.fromJson({
        "ocrResults": jsonDecode(normalizedText),
        "ocr_type": ocr_type ?? "OTHER",
      });

      if (isPrint) {
        for (final element in ocrResultInfo.ocrResults ?? const []) {
          debugPrint(element.toString());
        }
      }

      if ((ocrResultInfo.ocrResults ?? const []).isEmpty) {
        ocrResultInfo.ocr_type = "EMPTY";
      }
      return ocrResultInfo;
    } catch (_) {
      return null;
    }
  }
}
