import "dart:io";

import "package:flutter/foundation.dart";

import "ledger_ocr_engine.dart";
import "ledger_page_parser.dart";

class AndroidLedgerOcrEngine implements LedgerOcrEngine {
  AndroidLedgerOcrEngine({
    required LedgerOcrEngine primary,
    required LedgerOcrEngine fallback,
  })  : _primary = primary,
        _fallback = fallback;

  final LedgerOcrEngine _primary;
  final LedgerOcrEngine _fallback;

  @override
  Future<OcrLedgerParseResult> recognizeImage(
    File image, {
    required int pageIndex,
  }) async {
    final primaryResult = await _primary.recognizeImage(
      image,
      pageIndex: pageIndex,
    );
    if (_isUseful(primaryResult)) {
      return primaryResult;
    }

    debugPrint(
      "PaddleOCR page $pageIndex did not yield importable entries, "
      "falling back to ML Kit.",
    );

    final fallbackResult = await _fallback.recognizeImage(
      image,
      pageIndex: pageIndex,
    );
    return _pickBetter(primaryResult, fallbackResult);
  }

  bool _isUseful(OcrLedgerParseResult result) {
    return result.entries.isNotEmpty || result.rawText.trim().isNotEmpty;
  }

  OcrLedgerParseResult _pickBetter(
    OcrLedgerParseResult primaryResult,
    OcrLedgerParseResult fallbackResult,
  ) {
    if (fallbackResult.entries.length > primaryResult.entries.length) {
      return fallbackResult;
    }
    if (primaryResult.entries.length > fallbackResult.entries.length) {
      return primaryResult;
    }

    if (fallbackResult.rawText.trim().length >
        primaryResult.rawText.trim().length) {
      return fallbackResult;
    }

    return primaryResult;
  }

  @override
  Future<void> close() async {
    await _primary.close();
    await _fallback.close();
  }
}
