import "dart:convert";
import "dart:io";
import "dart:ui";

import "package:http/http.dart" as http;

import "ledger_ocr_engine.dart";
import "ledger_page_parser.dart";

class HttpLedgerOcrEngine implements LedgerOcrEngine {
  HttpLedgerOcrEngine({
    this.apiUrl = "http://localhost:9000/api/system/ai/analyze-image",
  });

  final String apiUrl;

  @override
  Future<OcrLedgerParseResult> recognizeImage(
    File image, {
    required int pageIndex,
  }) async {
    final request = http.MultipartRequest("POST", Uri.parse(apiUrl));
    request.files.add(await http.MultipartFile.fromPath("image", image.path));

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode != 200) {
      throw StateError(
        "OCR 服务请求失败 (${streamedResponse.statusCode}): $responseBody",
      );
    }

    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException("OCR 服务返回格式异常");
    }

    final chunks = _parseChunks(decoded);
    final rawText = _extractRawText(decoded, chunks);

    return LedgerPageParser.parseChunks(
      chunks,
      pageIndex: pageIndex,
      rawText: rawText,
    );
  }

  @override
  Future<void> close() async {}

  /// Extracts raw text from the response, falling back to joining chunk texts.
  String _extractRawText(Map<String, dynamic> response, List<OcrTextChunk> chunks) {
    final data = response["data"];
    if (data is Map<String, dynamic>) {
      final rawText = data["raw_text"] ?? data["rawText"];
      if (rawText is String && rawText.trim().isNotEmpty) return rawText;
    }
    return chunks.map((c) => c.text).join("\n");
  }

  /// Parses OCR chunks from various common JSON response formats.
  List<OcrTextChunk> _parseChunks(Map<String, dynamic> response) {
    // Check for error codes
    if (response["code"] is num && response["code"] != 200) {
      final msg = response["message"]?.toString() ?? "未知错误";
      throw StateError("OCR 服务返回错误: $msg");
    }

    final data = response["data"];
    if (data == null) return [];

    if (data is List) {
      return data.map(_parseChunk).toList();
    }

    if (data is Map<String, dynamic>) {
      final chunks = data["chunks"] ?? data["results"] ?? data["ocrResult"];
      if (chunks is List) {
        return chunks.map(_parseChunk).toList();
      }
    }

    return [];
  }

  /// Parses a single chunk from one of several supported JSON shapes.
  ///
  /// Supported formats:
  ///   { "text": "...", "bounds": { "left": x, "top": y, "width": w, "height": h } }
  ///   { "text": "...", "x": l, "y": t, "width": w, "height": h }
  ///   { "name": "...", "bounds": [{ "x": ..., "y": ... }, ...] }  // PaddleOCR polygon
  ///   { "name": "...", "x": l, "y": t, "w": w, "h": h }
  OcrTextChunk _parseChunk(dynamic item) {
    if (item is! Map<String, dynamic>) {
      return OcrTextChunk(text: item?.toString() ?? "", bounds: Rect.zero);
    }

    final text = (item["text"] ?? item["name"] ?? "").toString().trim();

    final bounds = item["bounds"];
    if (bounds is Map<String, dynamic>) {
      // { "bounds": { "left"/"x": ..., "top"/"y": ..., "width"/"w": ..., "height"/"h": ... } }
      return OcrTextChunk(
        text: text,
        bounds: Rect.fromLTWH(
          _toDouble(bounds["left"] ?? bounds["x"] ?? 0),
          _toDouble(bounds["top"] ?? bounds["y"] ?? 0),
          _toDouble(bounds["width"] ?? bounds["w"] ?? 0),
          _toDouble(bounds["height"] ?? bounds["h"] ?? 0),
        ),
      );
    }

    if (bounds is List) {
      // PaddleOCR-style polygon bounds: [{ "x": ..., "y": ... }, ...]
      return OcrTextChunk(
        text: text,
        bounds: _boundsFromPoints(bounds),
      );
    }

    // Flattened fields
    return OcrTextChunk(
      text: text,
      bounds: Rect.fromLTWH(
        _toDouble(item["x"] ?? item["left"] ?? 0),
        _toDouble(item["y"] ?? item["top"] ?? 0),
        _toDouble(item["width"] ?? item["w"] ?? 0),
        _toDouble(item["height"] ?? item["h"] ?? 0),
      ),
    );
  }

  Rect _boundsFromPoints(List points) {
    if (points.isEmpty) return Rect.zero;

    double? minX, minY, maxX, maxY;
    for (final point in points) {
      if (point is Map) {
        final x = _toDouble(point["x"] ?? 0);
        final y = _toDouble(point["y"] ?? 0);
        minX = minX == null ? x : (x < minX ? x : minX);
        minY = minY == null ? y : (y < minY ? y : minY);
        maxX = maxX == null ? x : (x > maxX ? x : maxX);
        maxY = maxY == null ? y : (y > maxY ? y : maxY);
      }
    }
    if (minX == null || minY == null || maxX == null || maxY == null) {
      return Rect.zero;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
