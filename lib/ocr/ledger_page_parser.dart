import "dart:math";
import "dart:ui";

import "package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart";

class OcrTextChunk {
  const OcrTextChunk({
    required this.text,
    required this.bounds,
  });

  final String text;
  final Rect bounds;
}

class OcrLedgerImportDraft {
  const OcrLedgerImportDraft({
    required this.name,
    required this.amount,
    required this.sourceText,
    required this.pageIndex,
  });

  final String name;
  final int amount;
  final String sourceText;
  final int pageIndex;
}

class OcrLedgerParseResult {
  const OcrLedgerParseResult({
    required this.entries,
    required this.unmatchedTexts,
    required this.rawText,
    required this.pageIndex,
  });

  final List<OcrLedgerImportDraft> entries;
  final List<String> unmatchedTexts;
  final String rawText;
  final int pageIndex;
}

class LedgerPageParser {
  static const _amountUnits = {
    "十": 10,
    "拾": 10,
    "百": 100,
    "佰": 100,
    "千": 1000,
    "仟": 1000,
    "万": 10000,
    "萬": 10000,
  };

  static const _amountDigits = {
    "零": 0,
    "〇": 0,
    "○": 0,
    "O": 0,
    "o": 0,
    "一": 1,
    "壹": 1,
    "二": 2,
    "贰": 2,
    "貳": 2,
    "两": 2,
    "兩": 2,
    "三": 3,
    "叁": 3,
    "四": 4,
    "肆": 4,
    "五": 5,
    "伍": 5,
    "六": 6,
    "陆": 6,
    "陸": 6,
    "七": 7,
    "柒": 7,
    "八": 8,
    "捌": 8,
    "九": 9,
    "玖": 9,
  };

  static const _nameStopwords = {
    "贺礼",
    "賀禮",
    "礼金",
    "禮金",
    "收礼",
    "收禮",
    "随礼",
    "隨禮",
    "人情",
    "账本",
    "賬本",
    "金额",
    "金額",
    "合计",
    "合計",
  };

  static OcrLedgerParseResult parseRecognizedText(
    RecognizedText recognizedText, {
    required int pageIndex,
  }) {
    final chunks = <OcrTextChunk>[];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final text = _normalizeWhitespace(line.text);
        if (text.isEmpty) continue;
        chunks.add(
          OcrTextChunk(
            text: text,
            bounds: line.boundingBox,
          ),
        );
      }
    }

    return parseChunks(
      chunks,
      pageIndex: pageIndex,
      rawText: recognizedText.text.trim(),
    );
  }

  static OcrLedgerParseResult parseChunks(
    List<OcrTextChunk> chunks, {
    required int pageIndex,
    String rawText = "",
  }) {
    if (chunks.isEmpty) {
      return OcrLedgerParseResult(
        entries: const [],
        unmatchedTexts: rawText.isEmpty ? const [] : [rawText],
        rawText: rawText,
        pageIndex: pageIndex,
      );
    }

    final groups = _groupChunks(chunks);
    final entries = <OcrLedgerImportDraft>[];
    final unmatchedTexts = <String>[];
    final seenKeys = <String>{};

    for (final group in groups) {
      final orderedGroup = [...group]..sort(
          (a, b) => a.bounds.top.compareTo(b.bounds.top),
        );
      final groupTexts = orderedGroup
          .map((chunk) => _normalizeWhitespace(chunk.text))
          .where((text) => text.isNotEmpty)
          .toList(growable: false);
      if (groupTexts.isEmpty) continue;

      final sourceText = groupTexts.join(" ");
      final amount = _extractAmount(groupTexts) ?? _extractAmount([sourceText]);
      final name = _extractName(groupTexts) ??
          _extractStructuredName(groupTexts) ??
          _extractName([sourceText]);

      if (name != null && amount != null) {
        final key = "$pageIndex|$name|$amount";
        if (seenKeys.add(key)) {
          entries.add(
            OcrLedgerImportDraft(
              name: name,
              amount: amount,
              sourceText: sourceText,
              pageIndex: pageIndex,
            ),
          );
        }
      } else {
        unmatchedTexts.add(sourceText);
      }
    }

    if (entries.isEmpty && rawText.isNotEmpty) {
      unmatchedTexts
        ..clear()
        ..add(rawText);
    }

    return OcrLedgerParseResult(
      entries: entries,
      unmatchedTexts: unmatchedTexts.toSet().toList(growable: false),
      rawText: rawText,
      pageIndex: pageIndex,
    );
  }

  static List<List<OcrTextChunk>> _groupChunks(List<OcrTextChunk> chunks) {
    final groupByX = _shouldGroupByX(chunks);
    final sorted = [...chunks]..sort((a, b) {
        final left = groupByX ? b.bounds.center.dx : a.bounds.center.dy;
        final right = groupByX ? a.bounds.center.dx : b.bounds.center.dy;
        return left.compareTo(right);
      });

    final groupSizes = sorted
        .map((chunk) => groupByX ? chunk.bounds.width : chunk.bounds.height)
        .where((size) => size > 0)
        .toList(growable: false);
    final mergeThreshold = max(24.0, _median(groupSizes) * 1.2);

    final groups = <List<OcrTextChunk>>[];
    for (final chunk in sorted) {
      if (groups.isEmpty) {
        groups.add([chunk]);
        continue;
      }

      final lastGroup = groups.last;
      final anchor = _groupAnchor(lastGroup, groupByX);
      final center = groupByX ? chunk.bounds.center.dx : chunk.bounds.center.dy;
      if ((center - anchor).abs() <= mergeThreshold) {
        lastGroup.add(chunk);
      } else {
        groups.add([chunk]);
      }
    }

    return groups;
  }

  static bool _shouldGroupByX(List<OcrTextChunk> chunks) {
    if (chunks.isEmpty) return true;
    var verticalLikeCount = 0;
    for (final chunk in chunks) {
      if (chunk.bounds.height >= chunk.bounds.width) {
        verticalLikeCount += 1;
      }
    }
    return verticalLikeCount * 2 >= chunks.length;
  }

  static double _groupAnchor(List<OcrTextChunk> group, bool groupByX) {
    final centers = group
        .map((chunk) =>
            groupByX ? chunk.bounds.center.dx : chunk.bounds.center.dy)
        .toList(growable: false);
    return centers.reduce((value, element) => value + element) / centers.length;
  }

  static double _median(List<double> values) {
    if (values.isEmpty) return 0;
    final sorted = [...values]..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[middle];
    return (sorted[middle - 1] + sorted[middle]) / 2;
  }

  static int? _extractAmount(Iterable<String> texts) {
    final candidates = <int>{};
    for (final text in texts) {
      candidates.addAll(_extractArabicAmounts(text));
      final chineseAmount = _extractChineseAmount(text);
      if (chineseAmount != null) {
        candidates.add(chineseAmount);
      }
    }

    if (candidates.isEmpty) return null;
    final sorted = candidates.toList()..sort();
    return sorted.last;
  }

  static Iterable<int> _extractArabicAmounts(String text) sync* {
    final normalized =
        _normalizeDigits(text).replaceAll(RegExp(r"[,，.\s]"), "");
    final pattern = RegExp(r"(?<!\d)(\d{2,6})(?!\d)");
    for (final match in pattern.allMatches(normalized)) {
      final value = int.tryParse(match.group(1)!);
      if (value != null && value > 0) {
        yield value;
      }
    }
  }

  static int? _extractChineseAmount(String text) {
    final compact = _normalizeWhitespace(text);
    if (!_looksLikeChineseAmountText(compact)) return null;

    final amountText = compact.replaceAll(
      RegExp(r"[^零〇○一二三四五六七八九十百千万萬壹贰貳叁肆伍陆陸柒捌玖拾佰仟两兩元圆圓整正]"),
      "",
    );
    if (amountText.isEmpty) return null;

    var total = 0;
    var section = 0;
    var number = 0;

    for (final rune in amountText.runes) {
      final char = String.fromCharCode(rune);
      final digit = _amountDigits[char];
      if (digit != null) {
        number = digit;
        continue;
      }

      final unit = _amountUnits[char];
      if (unit == null) {
        continue;
      }

      if (unit >= 10000) {
        section += number;
        total += max(section, 1) * unit;
        section = 0;
        number = 0;
        continue;
      }

      section += max(number, 1) * unit;
      number = 0;
    }

    final value = total + section + number;
    return value > 0 ? value : null;
  }

  static String? _extractName(Iterable<String> texts) {
    _ScoredCandidate<String>? bestCandidate;

    for (final text in texts) {
      final candidate = _normalizeNameCandidate(text);
      if (candidate.isEmpty) continue;

      final score = _scoreNameCandidate(text, candidate);
      if (score < 20) continue;

      if (bestCandidate == null || score > bestCandidate.score) {
        bestCandidate = _ScoredCandidate(value: candidate, score: score);
      }
    }

    return bestCandidate?.value;
  }

  static String? _extractStructuredName(List<String> texts) {
    if (texts.isEmpty) return null;

    final normalizedTexts = texts
        .map(_normalizeWhitespace)
        .where((text) => text.isNotEmpty)
        .toList(growable: false);
    final collected = <String>[];
    String? bestCandidate;

    for (var index = 0; index < normalizedTexts.length; index++) {
      if (_startsAmountOrMarkerSequence(normalizedTexts, index)) {
        break;
      }

      final candidate = _normalizeNameCandidate(normalizedTexts[index]);
      if (candidate.isEmpty) {
        if (collected.isNotEmpty) {
          break;
        }
        continue;
      }

      if (_looksLikeChineseAmountText(candidate)) {
        break;
      }

      collected.add(candidate);
      final joined = collected.join();
      if (joined.length > 4) {
        collected.removeLast();
        break;
      }

      if (joined.length >= 2) {
        bestCandidate = joined;
      }
    }

    return bestCandidate;
  }

  static bool _startsAmountOrMarkerSequence(
      List<String> texts, int startIndex) {
    for (var length = 1; length <= 4; length++) {
      final sample = _joinTexts(texts, startIndex, length);
      if (sample.isEmpty) continue;

      if (_nameStopwords.contains(sample)) {
        return true;
      }
      if (_extractAmount([sample]) != null) {
        return true;
      }
      if (_looksLikeChineseAmountText(sample)) {
        return true;
      }
    }

    return false;
  }

  static String _joinTexts(List<String> texts, int startIndex, int length) {
    if (startIndex >= texts.length) return "";
    final endIndex = min(texts.length, startIndex + length);
    return texts.sublist(startIndex, endIndex).join();
  }

  static String _normalizeNameCandidate(String text) {
    var candidate = _normalizeWhitespace(text);
    for (final stopword in _nameStopwords) {
      candidate = candidate.replaceAll(stopword, "");
    }
    candidate = candidate.replaceAll(RegExp(r"[0-9０-９A-Za-z]"), "");
    candidate = candidate.replaceAll(RegExp(r"[^\u4E00-\u9FFF]"), "");
    return candidate.trim();
  }

  static int _scoreNameCandidate(String original, String candidate) {
    if (candidate.length < 2 || candidate.length > 4) return -100;
    if (_looksLikeChineseAmountText(candidate)) return -100;

    var score = 40;
    if (candidate.length == 3) {
      score += 12;
    } else if (candidate.length == 2 || candidate.length == 4) {
      score += 8;
    }

    if (!_looksLikeChineseAmountText(original)) {
      score += 18;
    }
    if (!_containsAny(original, const ["元", "整", "贺礼", "賀禮", "礼金", "禮金"])) {
      score += 12;
    }
    if (candidate.runes.toSet().length == 1) {
      score -= 8;
    }

    return score;
  }

  static bool _looksLikeChineseAmountText(String text) {
    final compact = _normalizeWhitespace(text);
    if (compact.isEmpty) return false;
    if (_containsAny(compact, const ["元", "圆", "圓", "整", "正"])) return true;

    final allowedOnly = compact.replaceAll(
      RegExp(r"[零〇○一二三四五六七八九十百千万萬壹贰貳叁肆伍陆陸柒捌玖拾佰仟两兩]"),
      "",
    );
    return allowedOnly.isEmpty && compact.length >= 2;
  }

  static bool _containsAny(String text, Iterable<String> patterns) {
    for (final pattern in patterns) {
      if (text.contains(pattern)) return true;
    }
    return false;
  }

  static String _normalizeDigits(String text) {
    const fullWidthDigits = {
      "０": "0",
      "１": "1",
      "２": "2",
      "３": "3",
      "４": "4",
      "５": "5",
      "６": "6",
      "７": "7",
      "８": "8",
      "９": "9",
    };

    var normalized = text;
    fullWidthDigits.forEach((key, value) {
      normalized = normalized.replaceAll(key, value);
    });
    return normalized;
  }

  static String _normalizeWhitespace(String text) {
    return text.replaceAll(RegExp(r"\s+"), " ").trim();
  }
}

class _ScoredCandidate<T> {
  const _ScoredCandidate({
    required this.value,
    required this.score,
  });

  final T value;
  final int score;
}
