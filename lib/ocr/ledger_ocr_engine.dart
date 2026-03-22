import "dart:io";

import "android_ledger_ocr_engine.dart";
import "ledger_page_parser.dart";
import "mlkit_ledger_ocr_engine.dart";
import "paddle_ledger_ocr_engine.dart";

abstract class LedgerOcrEngine {
  Future<OcrLedgerParseResult> recognizeImage(
    File image, {
    required int pageIndex,
  });

  Future<void> close() async {}
}

LedgerOcrEngine createLedgerOcrEngine() {
  if (Platform.isAndroid) {
    return AndroidLedgerOcrEngine(
      primary: PaddleLedgerOcrEngine(),
      fallback: MlKitLedgerOcrEngine(),
    );
  }
  if (Platform.isIOS) {
    return MlKitLedgerOcrEngine();
  }
  return const UnsupportedLedgerOcrEngine();
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
