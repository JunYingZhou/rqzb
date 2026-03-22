import "dart:io";

import "package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart";

import "ledger_ocr_engine.dart";
import "ledger_page_parser.dart";

class MlKitLedgerOcrEngine implements LedgerOcrEngine {
  MlKitLedgerOcrEngine()
      : _textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);

  final TextRecognizer _textRecognizer;

  @override
  Future<OcrLedgerParseResult> recognizeImage(
    File image, {
    required int pageIndex,
  }) async {
    final inputImage = InputImage.fromFile(image);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return LedgerPageParser.parseRecognizedText(
      recognizedText,
      pageIndex: pageIndex,
    );
  }

  @override
  Future<void> close() {
    return _textRecognizer.close();
  }
}
