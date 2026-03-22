import "dart:io";
import "dart:ui";

import "package:flutter/foundation.dart";
import "package:paddle_ocr/bean/ocr_result.dart";
import "package:paddle_ocr/bean/ocr_results.dart";
import "package:paddle_ocr/bean/point.dart" as paddle;
import "package:paddle_ocr/paddle_ocr.dart";

import "ledger_ocr_engine.dart";
import "ledger_page_parser.dart";

class PaddleLedgerOcrEngine implements LedgerOcrEngine {
  @override
  Future<OcrLedgerParseResult> recognizeImage(
    File image, {
    required int pageIndex,
  }) async {
    final result = await PaddleOcr.ocrFromImage(image.path);
    final success = result["success"] == true;
    if (!success) {
      throw StateError(result["message"]?.toString() ?? "PaddleOCR 识别失败");
    }

    final ocrInfo = result["ocrResult"];
    if (ocrInfo is! OcrResultInfo) {
      throw const FormatException("PaddleOCR 返回结果格式异常");
    }

    final parsedResult = parseOcrResultInfo(ocrInfo, pageIndex: pageIndex);
    debugPrint(
      "PaddleOCR page $pageIndex: "
      "${parsedResult.entries.length} entries, "
      "${parsedResult.unmatchedTexts.length} unmatched",
    );
    if (parsedResult.rawText.trim().isNotEmpty) {
      debugPrint("PaddleOCR raw page $pageIndex:\n${parsedResult.rawText}");
    }
    return parsedResult;
  }

  @override
  Future<void> close() async {}

  static OcrLedgerParseResult parseOcrResultInfo(
    OcrResultInfo ocrInfo, {
    required int pageIndex,
  }) {
    final results = ocrInfo.ocrResults ?? const <OcrResult>[];
    final chunks =
        results.map(_toChunk).whereType<OcrTextChunk>().toList(growable: false);
    final rawText = results
        .map((result) => result.name?.trim() ?? "")
        .where((text) => text.isNotEmpty)
        .join("\n");

    return LedgerPageParser.parseChunks(
      chunks,
      pageIndex: pageIndex,
      rawText: rawText,
    );
  }

  static OcrTextChunk? _toChunk(OcrResult result) {
    final text = result.name?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    return OcrTextChunk(
      text: text,
      bounds: _boundsFromPoints(result.bounds),
    );
  }

  static Rect _boundsFromPoints(List<paddle.Point>? points) {
    if (points == null || points.isEmpty) {
      return Rect.zero;
    }

    var minX = points.first.x ?? 0;
    var minY = points.first.y ?? 0;
    var maxX = minX;
    var maxY = minY;

    for (final point in points.skip(1)) {
      final x = point.x ?? 0;
      final y = point.y ?? 0;
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}
