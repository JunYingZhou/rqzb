import "dart:convert";
import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:renqing_ledger/ocr/http_ledger_ocr_engine.dart";

void main() {
  test("uploads image as file and maps backend records into import drafts",
      () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);

    final requestFuture = server.first;
    final image = await File(
      "${Directory.systemTemp.path}${Platform.pathSeparator}"
      "renqing_ocr_test_${DateTime.now().microsecondsSinceEpoch}.jpg",
    ).writeAsBytes([1, 2, 3]);
    addTearDown(() async {
      if (await image.exists()) {
        await image.delete();
      }
    });

    Future<void> respond() async {
      final request = await requestFuture;
      expect(request.method, "POST");
      expect(request.uri.path, "/api/system/ai/analyze-image");
      expect(request.headers.contentType?.mimeType, "multipart/form-data");

      final body = await utf8.decoder.bind(request).join();
      expect(body, contains('name="file"'));
      expect(body, contains("renqing_ocr_test_"));

      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({
          "code": 200,
          "message": "success",
          "data": {
            "fileName": "renqin.jpg",
            "contentType": "image/jpeg",
            "size": 171254,
            "result": jsonEncode({
              "filename": "renqin.jpg",
              "model": "qwen2.5-vl-7b-instruct",
              "result": {
                "scene": "礼金登记簿",
                "records": [
                  {
                    "index": 1,
                    "name": "熊丙文",
                    "amount": 500,
                    "amount_text": "伍佰元整",
                    "confidence": 0.87,
                  },
                  {
                    "index": 2,
                    "name": "李良坤",
                    "amount": 600,
                    "amount_text": "陆佰元整",
                    "confidence": 0.93,
                  },
                ],
                "calculated_total": 1100,
                "backend_calculated_total": 1100,
                "is_total_matched": true,
                "uncertain_records": [],
                "notes": "",
              },
            }),
          },
        }));
      await request.response.close();
    }

    final responseTask = respond();
    final engine = HttpLedgerOcrEngine(
      apiUrl:
          "http://${server.address.host}:${server.port}/api/system/ai/analyze-image",
    );

    final result = await engine.recognizeImage(image, pageIndex: 3);

    expect(result.pageIndex, 3);
    expect(result.entries, hasLength(2));
    expect(result.entries[0].name, "熊丙文");
    expect(result.entries[0].amount, 500);
    expect(result.entries[0].sourceText, "熊丙文 伍佰元整 500");
    expect(result.entries[1].name, "李良坤");
    expect(result.entries[1].amount, 600);
    expect(result.rawText, contains("礼金登记簿"));
    await responseTask;
  });
}
