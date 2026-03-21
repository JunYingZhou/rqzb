import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:renqing_ledger/data/record_occasion.dart";
import "package:renqing_ledger/ocr/ledger_page_parser.dart";
import "package:renqing_ledger/pages/ocr_import_preview_page.dart";

void main() {
  testWidgets("renders OCR import preview", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OcrImportPreviewPage(
          parseResults: const [
            OcrLedgerParseResult(
              entries: [
                OcrLedgerImportDraft(
                  name: "张三",
                  amount: 500,
                  sourceText: "张三 贺礼 伍佰元整",
                  pageIndex: 1,
                ),
              ],
              unmatchedTexts: ["合计 壹万两仟元整"],
              rawText: "张三 贺礼 伍佰元整",
              pageIndex: 1,
            ),
          ],
          occasion: RecordOccasion.wedding,
          date: DateTime(2026, 3, 22),
          type: "收礼",
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("确认导入"), findsOneWidget);
    expect(find.text("张三"), findsOneWidget);
    expect(find.text("500"), findsOneWidget);
    expect(find.text("导入记录"), findsOneWidget);
  });
}
