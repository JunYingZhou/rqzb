import "package:flutter/material.dart";

import "../data/isar_db.dart";
import "../data/record_occasion.dart";
import "../data/renqing_record.dart";
import "../ocr/ledger_page_parser.dart";
import "../theme/semantic_colors.dart";

class OcrImportPreviewPage extends StatefulWidget {
  const OcrImportPreviewPage({
    super.key,
    required this.parseResults,
    required this.occasion,
    required this.date,
    required this.type,
  });

  final List<OcrLedgerParseResult> parseResults;
  final RecordOccasion occasion;
  final DateTime date;
  final String type;

  @override
  State<OcrImportPreviewPage> createState() => _OcrImportPreviewPageState();
}

class _OcrImportPreviewPageState extends State<OcrImportPreviewPage> {
  final _formKey = GlobalKey<FormState>();
  final List<_EditableImportDraft> _drafts = [];
  var _draftIdSeed = 0;
  var _isSaving = false;

  bool get _isReceived => widget.type == "收礼";
  Color get _typeColor =>
      _isReceived ? receivedSemanticColor : sentSemanticColor;

  @override
  void initState() {
    super.initState();
    for (final result in widget.parseResults) {
      for (final entry in result.entries) {
        _drafts.add(
          _createDraft(
            name: entry.name,
            amount: entry.amount,
            pageIndex: entry.pageIndex,
            sourceText: entry.sourceText,
          ),
        );
      }
    }

    if (_drafts.isEmpty) {
      _drafts.add(_createDraft(pageIndex: 1));
    }
  }

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  _EditableImportDraft _createDraft({
    String name = "",
    int? amount,
    required int pageIndex,
    String sourceText = "",
  }) {
    final draft = _EditableImportDraft(
      id: "ocr-draft-${_draftIdSeed++}",
      name: name,
      amount: amount,
      pageIndex: pageIndex,
      sourceText: sourceText,
      onChanged: _handleDraftChanged,
    );
    return draft;
  }

  void _handleDraftChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _addEmptyDraft() {
    setState(() {
      _drafts.add(
        _createDraft(
          pageIndex: widget.parseResults.isEmpty
              ? 1
              : widget.parseResults.first.pageIndex,
        ),
      );
    });
  }

  void _removeDraft(_EditableImportDraft draft) {
    if (_drafts.length == 1) {
      draft.nameController.clear();
      draft.amountController.clear();
      return;
    }

    setState(() {
      _drafts.remove(draft);
      draft.dispose();
    });
  }

  int get _validDraftCount {
    return _drafts.where((draft) => draft.isValid).length;
  }

  int get _unmatchedCount {
    return widget.parseResults.fold<int>(
      0,
      (sum, result) => sum + result.unmatchedTexts.length,
    );
  }

  Future<void> _importDrafts() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      _showSnackBar("请先修正姓名和金额");
      return;
    }

    final validDrafts =
        _drafts.where((draft) => draft.isValid).toList(growable: false);
    if (validDrafts.isEmpty) {
      _showSnackBar("请至少保留一条有效记录");
      return;
    }

    setState(() => _isSaving = true);
    try {
      await PersonRepository.ensureNames(
        validDrafts.map((draft) => draft.normalizedName),
      );

      final importedAt = DateTime.now();
      final records = validDrafts.map((draft) {
        final amount = draft.parsedAmount!;
        return RenqingRecord()
          ..type = widget.type
          ..name = draft.normalizedName
          ..relationship = "其他"
          ..relationshipNote = null
          ..occasion = widget.occasion.label
          ..amount = _isReceived ? amount : -amount
          ..date = widget.date
          ..note = _buildImportNote(draft.pageIndex)
          ..createdAt = importedAt;
      }).toList(growable: false);

      await RecordRepository.addAll(records);

      if (!mounted) return;
      Navigator.of(context).pop(records.length);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar("导入失败，请稍后再试");
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _buildImportNote(int pageIndex) {
    if (widget.parseResults.length <= 1) {
      return "OCR导入";
    }
    return "OCR导入·第$pageIndex页";
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasRawText =
        widget.parseResults.any((result) => result.rawText.trim().isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: const Text("确认导入"),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _addEmptyDraft,
            icon: const Icon(Icons.add),
            label: const Text("新增一条"),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "可导入 $_validDraftCount 条记录",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "导入后会自动写入记录，并补齐联系人姓名。",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _isSaving ? null : _importDrafts,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(_isSaving ? "导入中" : "导入记录"),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _HeroSummaryCard(
              color: _typeColor,
              occasion: widget.occasion.label,
              date: _formatDate(widget.date),
              type: widget.type,
              draftCount: _drafts.length,
              unmatchedCount: _unmatchedCount,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryStatCard(
                    label: "自动识别",
                    value:
                        "${widget.parseResults.fold<int>(0, (sum, item) => sum + item.entries.length)} 条",
                    icon: Icons.auto_awesome_outlined,
                    tint: _typeColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryStatCard(
                    label: "待确认片段",
                    value: "$_unmatchedCount 段",
                    icon: Icons.rule_folder_outlined,
                    tint: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.tips_and_updates_outlined, color: _typeColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "我先帮你抽取了姓名和金额。导入前你可以改名字、改金额、删掉误识别的行，也可以手动补一条。",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "待导入记录",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _isSaving ? null : _addEmptyDraft,
                  icon: const Icon(Icons.add),
                  label: const Text("补一条"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < _drafts.length; index++) ...[
              _OcrDraftCard(
                key: ValueKey(_drafts[index].id),
                index: index + 1,
                draft: _drafts[index],
                tint: _typeColor,
                showPageTag: widget.parseResults.length > 1,
                onRemove: _isSaving ? null : () => _removeDraft(_drafts[index]),
              ),
              const SizedBox(height: 12),
            ],
            if (hasRawText) ...[
              const SizedBox(height: 12),
              Text(
                "原始识别文本",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.parseResults
                  .where((result) => result.rawText.trim().isNotEmpty)
                  .map(
                    (result) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RawTextCard(
                        result: result,
                        tint: _typeColor,
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";
  }
}

class _HeroSummaryCard extends StatelessWidget {
  const _HeroSummaryCard({
    required this.color,
    required this.occasion,
    required this.date,
    required this.type,
    required this.draftCount,
    required this.unmatchedCount,
  });

  final Color color;
  final String occasion;
  final String date;
  final String type;
  final int draftCount;
  final int unmatchedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF7EF),
            color.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.document_scanner_outlined,
                    color: color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "账本页 OCR 已就绪",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "先确认每一条，再一次性导入到人情账本。",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                    icon: Icons.event_available_outlined,
                    label: occasion,
                    color: color),
                _InfoChip(
                    icon: Icons.calendar_month_outlined,
                    label: date,
                    color: color),
                _InfoChip(
                    icon: Icons.swap_horiz_outlined, label: type, color: color),
                _InfoChip(
                    icon: Icons.list_alt_outlined,
                    label: "$draftCount 条草稿",
                    color: color),
                if (unmatchedCount > 0)
                  _InfoChip(
                      icon: Icons.warning_amber_outlined,
                      label: "$unmatchedCount 段待确认",
                      color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: tint, size: 22),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OcrDraftCard extends StatelessWidget {
  const _OcrDraftCard({
    super.key,
    required this.index,
    required this.draft,
    required this.tint,
    required this.showPageTag,
    required this.onRemove,
  });

  final int index;
  final _EditableImportDraft draft;
  final Color tint;
  final bool showPageTag;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$index",
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: tint,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "账本记录",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (showPageTag)
                        Text(
                          "第 ${draft.pageIndex} 页",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  tooltip: "删除这条",
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: draft.nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: "姓名",
                hintText: "请输入姓名",
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "姓名不能为空";
                }
                if (value.trim().length < 2) {
                  return "姓名至少 2 个字";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: draft.amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "金额",
                hintText: "请输入正整数",
                prefixIcon: Icon(Icons.currency_yen_outlined),
              ),
              validator: (value) {
                final amount = int.tryParse((value ?? "").trim());
                if (amount == null || amount <= 0) {
                  return "金额需为正整数";
                }
                return null;
              },
            ),
            if (draft.sourceText.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "识别片段",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      draft.sourceText,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RawTextCard extends StatelessWidget {
  const _RawTextCard({
    required this.result,
    required this.tint,
  });

  final OcrLedgerParseResult result;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.article_outlined, color: tint),
        title: Text("第 ${result.pageIndex} 页原始文本"),
        subtitle: result.unmatchedTexts.isEmpty
            ? const Text("已完成自动抽取")
            : Text("还有 ${result.unmatchedTexts.length} 段未自动抽取"),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (result.unmatchedTexts.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                result.unmatchedTexts.join("\n"),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SelectableText(result.rawText),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF4C3830),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _EditableImportDraft {
  _EditableImportDraft({
    required this.id,
    required String name,
    required int? amount,
    required this.pageIndex,
    required this.sourceText,
    required VoidCallback onChanged,
  })  : nameController = TextEditingController(text: name),
        amountController = TextEditingController(
          text: amount == null ? "" : amount.toString(),
        ),
        _onChanged = onChanged {
    nameController.addListener(_onChanged);
    amountController.addListener(_onChanged);
  }

  final String id;
  final int pageIndex;
  final String sourceText;
  final TextEditingController nameController;
  final TextEditingController amountController;
  final VoidCallback _onChanged;

  String get normalizedName => nameController.text.trim();

  int? get parsedAmount => int.tryParse(amountController.text.trim());

  bool get isValid {
    final amount = parsedAmount;
    return normalizedName.isNotEmpty && amount != null && amount > 0;
  }

  void dispose() {
    nameController.removeListener(_onChanged);
    amountController.removeListener(_onChanged);
    nameController.dispose();
    amountController.dispose();
  }
}
