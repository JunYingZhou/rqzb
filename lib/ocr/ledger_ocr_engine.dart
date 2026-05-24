import "dart:io";

import "http_ledger_ocr_engine.dart";
import "ledger_page_parser.dart";

abstract class LedgerOcrEngine {
  Future<OcrLedgerParseResult> recognizeImage(
    File image, {
    required int pageIndex,
  });

  Future<void> close() async {}
}

LedgerOcrEngine createLedgerOcrEngine() {
  return HttpLedgerOcrEngine();
}

class UnsupportedLedgerOcrEngine implements LedgerOcrEngine {
  const UnsupportedLedgerOcrEngine();

  @override
  Future<OcrLedgerParseResult> recognizeImage(
    File image, {
    required int pageIndex,
  }) {
    throw UnsupportedError("当前平台暂不支持 OCR 识别");
  }

  @override
  Future<void> close() async {}
}
