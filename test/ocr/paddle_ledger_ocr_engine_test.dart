import "package:flutter_test/flutter_test.dart";
import "package:paddle_ocr/bean/ocr_result.dart";
import "package:paddle_ocr/bean/ocr_results.dart";
import "package:paddle_ocr/bean/point.dart" as paddle;
import "package:renqing_ledger/ocr/paddle_ledger_ocr_engine.dart";

void main() {
  test("maps Paddle OCR result models into ledger parse results", () {
    final result = PaddleLedgerOcrEngine.parseOcrResultInfo(
      OcrResultInfo(
        ocrResults: [
          OcrResult(
            name: "王勇",
            bounds: [
              paddle.Point(x: 920, y: 80),
              paddle.Point(x: 962, y: 80),
              paddle.Point(x: 962, y: 200),
              paddle.Point(x: 920, y: 200),
            ],
          ),
          OcrResult(
            name: "贺礼",
            bounds: [
              paddle.Point(x: 922, y: 250),
              paddle.Point(x: 960, y: 250),
              paddle.Point(x: 960, y: 350),
              paddle.Point(x: 922, y: 350),
            ],
          ),
          OcrResult(
            name: "500",
            bounds: [
              paddle.Point(x: 924, y: 560),
              paddle.Point(x: 964, y: 560),
              paddle.Point(x: 964, y: 586),
              paddle.Point(x: 924, y: 586),
            ],
          ),
        ],
      ),
      pageIndex: 1,
    );

    expect(result.entries.length, 1);
    expect(result.entries.single.name, "王勇");
    expect(result.entries.single.amount, 500);
  });
}
