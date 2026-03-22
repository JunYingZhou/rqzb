import "dart:ui";

import "package:flutter_test/flutter_test.dart";
import "package:renqing_ledger/ocr/ledger_page_parser.dart";

void main() {
  group("LedgerPageParser", () {
    test("parses vertical ledger columns into drafts", () {
      final result = LedgerPageParser.parseChunks(
        [
          const OcrTextChunk(
            text: "王勇",
            bounds: Rect.fromLTWH(920, 80, 42, 120),
          ),
          const OcrTextChunk(
            text: "贺礼",
            bounds: Rect.fromLTWH(922, 250, 38, 100),
          ),
          const OcrTextChunk(
            text: "伍佰元整",
            bounds: Rect.fromLTWH(918, 390, 46, 150),
          ),
          const OcrTextChunk(
            text: "500",
            bounds: Rect.fromLTWH(924, 560, 40, 26),
          ),
          const OcrTextChunk(
            text: "李梅",
            bounds: Rect.fromLTWH(760, 84, 42, 120),
          ),
          const OcrTextChunk(
            text: "贺礼",
            bounds: Rect.fromLTWH(762, 252, 38, 100),
          ),
          const OcrTextChunk(
            text: "叁仟元整",
            bounds: Rect.fromLTWH(758, 394, 48, 150),
          ),
          const OcrTextChunk(
            text: "3000",
            bounds: Rect.fromLTWH(764, 564, 46, 28),
          ),
        ],
        pageIndex: 1,
      );

      expect(result.entries.length, 2);
      expect(result.entries[0].name, "王勇");
      expect(result.entries[0].amount, 500);
      expect(result.entries[1].name, "李梅");
      expect(result.entries[1].amount, 3000);
    });

    test("keeps unmatched text when no valid record is parsed", () {
      final result = LedgerPageParser.parseChunks(
        [
          const OcrTextChunk(
            text: "合计 壹万两仟元整",
            bounds: Rect.fromLTWH(100, 100, 300, 44),
          ),
        ],
        pageIndex: 2,
        rawText: "合计 壹万两仟元整",
      );

      expect(result.entries, isEmpty);
      expect(result.unmatchedTexts, isNotEmpty);
    });

    test("parses names split into single-character OCR boxes", () {
      final result = LedgerPageParser.parseChunks(
        [
          const OcrTextChunk(
            text: "王",
            bounds: Rect.fromLTWH(920, 80, 42, 58),
          ),
          const OcrTextChunk(
            text: "勇",
            bounds: Rect.fromLTWH(920, 150, 42, 58),
          ),
          const OcrTextChunk(
            text: "贺",
            bounds: Rect.fromLTWH(920, 250, 42, 58),
          ),
          const OcrTextChunk(
            text: "礼",
            bounds: Rect.fromLTWH(920, 320, 42, 58),
          ),
          const OcrTextChunk(
            text: "伍",
            bounds: Rect.fromLTWH(920, 390, 42, 58),
          ),
          const OcrTextChunk(
            text: "佰",
            bounds: Rect.fromLTWH(920, 460, 42, 58),
          ),
          const OcrTextChunk(
            text: "元",
            bounds: Rect.fromLTWH(920, 530, 42, 58),
          ),
          const OcrTextChunk(
            text: "整",
            bounds: Rect.fromLTWH(920, 600, 42, 58),
          ),
          const OcrTextChunk(
            text: "500",
            bounds: Rect.fromLTWH(924, 676, 40, 26),
          ),
        ],
        pageIndex: 3,
      );

      expect(result.entries.length, 1);
      expect(result.entries.single.name, "王勇");
      expect(result.entries.single.amount, 500);
    });
  });
}
