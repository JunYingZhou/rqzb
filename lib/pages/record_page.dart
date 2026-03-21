import "dart:io";

import "package:flutter/material.dart";
import "package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart";
import "package:image_cropper/image_cropper.dart";
import "package:image_picker/image_picker.dart";
import "../data/isar_db.dart";
import "../data/record_occasion.dart";
import "../data/renqing_record.dart";
import "../routes.dart";
import "../theme/semantic_colors.dart";
import "../widgets/edit_record_amount_dialog.dart";
import "../widgets/shell_scaffold.dart";

class _OcrContextDraft {
  const _OcrContextDraft({
    required this.occasion,
    required this.date,
  });

  final RecordOccasion occasion;
  final DateTime date;
}

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  static const int _maxImages = 5;

  final ImagePicker _picker = ImagePicker();
  late final TextRecognizer _textRecognizer;
  final List<File> _selectedImages = [];
  final List<String> _ocrResults = [];
  _OcrContextDraft? _ocrContext;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _startOcrFlow() async {
    if (_isProcessing) return;
    if (_selectedImages.length >= _maxImages) {
      _showSnackBar("最多只能识别$_maxImages张图片");
      return;
    }

    final ocrContext = await _showOcrContextDialog();
    if (!mounted || ocrContext == null) return;

    setState(() => _ocrContext = ocrContext);

    await _showPickOptions();
  }

  Future<_OcrContextDraft?> _showOcrContextDialog() async {
    final draft = _ocrContext;
    RecordOccasion? selectedOccasion = draft?.occasion;
    var selectedDate = draft?.date ?? DateTime.now();
    var showOccasionError = false;

    return showDialog<_OcrContextDraft>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text("填写本次识别信息"),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "场合",
                        style: Theme.of(dialogContext).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: RecordOccasion.values.map((option) {
                          return ChoiceChip(
                            label: Text(option.label),
                            selected: selectedOccasion == option,
                            onSelected: (_) {
                              setDialogState(() {
                                selectedOccasion = option;
                                showOccasionError = false;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (showOccasionError) ...[
                        const SizedBox(height: 12),
                        Text(
                          "请选择场合",
                          style: Theme.of(dialogContext)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color:
                                    Theme.of(dialogContext).colorScheme.error,
                              ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        "日期",
                        style: Theme.of(dialogContext).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedDate,
                            firstDate: DateTime(2010),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(_formatDate(selectedDate)),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("取消"),
                ),
                FilledButton(
                  onPressed: () {
                    final occasion = selectedOccasion;
                    if (occasion == null) {
                      setDialogState(() => showOccasionError = true);
                      return;
                    }

                    Navigator.of(dialogContext).pop(
                      _OcrContextDraft(
                        occasion: occasion,
                        date: selectedDate,
                      ),
                    );
                  },
                  child: const Text("下一步"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showPickOptions() async {
    if (_isProcessing) return;
    if (_selectedImages.length >= _maxImages) {
      _showSnackBar("最多只能识别$_maxImages张图片");
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final draft = _ocrContext;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (draft != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${draft.occasion.label} · ${_formatDate(draft.date)}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF6B5A60),
                            ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("拍照识别"),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("相册选择"),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickFromGallery();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromCamera() async {
    final remaining = _maxImages - _selectedImages.length;
    if (remaining <= 0) {
      _showSnackBar("最多只能识别$_maxImages张图片");
      return;
    }

    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    final cropped = await _cropImage(picked.path);
    if (!mounted || cropped == null) return;

    await _runOcr([cropped]);
  }

  Future<void> _pickFromGallery() async {
    final remaining = _maxImages - _selectedImages.length;
    if (remaining <= 0) {
      _showSnackBar("最多只能识别$_maxImages张图片");
      return;
    }

    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;

    final limited = picked.take(remaining).toList();
    if (picked.length > remaining) {
      _showSnackBar("已选择前$remaining张图片进行识别");
    }

    final List<File> croppedImages = [];
    for (final image in limited) {
      final cropped = await _cropImage(image.path);
      if (cropped != null) {
        croppedImages.add(cropped);
      }
    }

    if (!mounted || croppedImages.isEmpty) return;
    await _runOcr(croppedImages);
  }

  Future<File?> _cropImage(String path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "裁剪图片",
          toolbarColor: Theme.of(context).colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: "裁剪图片",
        ),
      ],
    );

    if (croppedFile == null) return null;
    return File(croppedFile.path);
  }

  Future<void> _runOcr(List<File> images) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    _showProcessingDialog();

    final List<String> results = [];
    for (final image in images) {
      final inputImage = InputImage.fromFile(image);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      results.add(recognizedText.text.trim());
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    setState(() {
      _isProcessing = false;
      _selectedImages.addAll(images);
      _ocrResults
        ..clear()
        ..addAll(results);
    });

    _showOcrResults(results);
  }

  void _showProcessingDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Expanded(child: Text("正在识别，请稍候...")),
            ],
          ),
        );
      },
    );
  }

  void _showOcrResults(List<String> results) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final draft = _ocrContext;
        return AlertDialog(
          title: const Text("OCR识别结果"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (draft != null) ...[
                    Text(
                      "${draft.occasion.label} · ${_formatDate(draft.date)}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B5A60),
                          ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (results.isEmpty)
                    const Text("未识别到文本")
                  else
                    ...results.map((text) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(text.isEmpty ? "未识别到文本" : text),
                      );
                    }),
                  const SizedBox(height: 4),
                  Text(
                    "识别内容的业务处理待接入",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B5A60),
                        ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("关闭"),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatAmount(int amount) {
    return "￥${amount.abs()}";
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";
  }

  String _relationshipLabel(RenqingRecord record) {
    if (record.relationship == "其他") {
      final note = record.relationshipNote?.trim();
      if (note != null && note.isNotEmpty) {
        return note;
      }
    }
    return record.relationship;
  }

  Future<void> _editRecordAmount(RenqingRecord record) async {
    final updatedAbsoluteAmount = await showEditRecordAmountDialog(
      context: context,
      record: record,
    );
    if (!mounted || updatedAbsoluteAmount == null) return;

    final nextAmount = record.amount.isNegative
        ? -updatedAbsoluteAmount
        : updatedAbsoluteAmount;
    if (nextAmount == record.amount) return;

    final didUpdate = await RecordRepository.updateAmount(
      id: record.id,
      amount: nextAmount,
    );
    if (!mounted) return;

    _showSnackBar(didUpdate ? "金额已更新" : "记录不存在，无法更新");
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<RenqingRecord>>(
      stream: RecordRepository.watchAll(),
      builder: (context, snapshot) {
        final records = snapshot.data ?? const <RenqingRecord>[];
        final income = records
            .where((record) => record.amount >= 0)
            .fold<int>(0, (sum, record) => sum + record.amount);
        final expense = records
            .where((record) => record.amount < 0)
            .fold<int>(0, (sum, record) => sum + record.amount.abs());

        return ShellScaffold(
          currentIndex: 0,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _isProcessing ? null : _startOcrFlow,
            icon: const Icon(Icons.document_scanner_outlined),
            label: const Text("OCR识别"),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  title: const Text("记录"),
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "本月概览",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: "收礼",
                                value: _formatAmount(income),
                                highlight: receivedSemanticColor,
                                icon: Icons.call_received,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: "随礼",
                                value: _formatAmount(expense),
                                highlight: sentSemanticColor,
                                icon: Icons.call_made,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _QuickActions(
                          onAdd: () {
                            Navigator.of(context)
                                .pushNamed(AppRoutes.addRecord);
                          },
                          onImport: () {},
                          onExport: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "最近记录",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            "${records.length} 条",
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (records.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.receipt_long_outlined,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "还没有记录",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "先新增一条，首页会自动更新最近记录。",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final record = records[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == records.length - 1 ? 0 : 12,
                            ),
                            child: _RecordTile(
                              key: ValueKey(record.id),
                              name: record.name,
                              category: record.occasion,
                              relationship: _relationshipLabel(record),
                              date: _formatDate(record.date),
                              amount: record.amount,
                              note: record.note,
                              onEdit: () => _editRecordAmount(record),
                            ),
                          );
                        },
                        childCount: records.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatefulWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.highlight,
    required this.icon,
  });

  final String label;
  final String value;
  final Color highlight;
  final IconData icon;

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 20.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Card(
              elevation: 2,
              shadowColor: const Color(0x1A000000),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      widget.highlight.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.highlight.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.highlight,
                              size: 20,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.trending_up,
                            color: widget.highlight,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF6B5A60),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.value,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: const Color(0xFF1B0A0F),
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onAdd,
    required this.onImport,
    required this.onExport,
  });

  final VoidCallback onAdd;
  final VoidCallback onImport;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: const Color(0x0F000000),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  "新增记录",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _ActionButton(
              onPressed: onImport,
              icon: Icons.file_upload_outlined,
              tooltip: "导入数据",
            ),
            const SizedBox(width: 8),
            _ActionButton(
              onPressed: onExport,
              icon: Icons.file_download_outlined,
              tooltip: "导出数据",
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.tooltip,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: IconButton.filledTonal(
          onPressed: widget.onPressed,
          icon: Icon(widget.icon, size: 20),
          tooltip: widget.tooltip,
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    super.key,
    required this.name,
    required this.category,
    required this.relationship,
    required this.date,
    required this.amount,
    this.note,
    required this.onEdit,
  });

  final String name;
  final String category;
  final String relationship;
  final String date;
  final int amount;
  final String? note;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = amount >= 0;
    final amountColor = isIncome ? receivedSemanticColor : sentSemanticColor;
    final amountText = "${isIncome ? "+" : "-"}￥${amount.abs()}";
    final noteText = note?.trim();
    final surface = colorScheme.surfaceContainerHighest.withValues(
      alpha: isDark ? 0.42 : 0.28,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                surface,
                isIncome
                    ? amountColor.withValues(alpha: 0.05)
                    : colorScheme.surface,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: amountColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: amountColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: amountColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              relationship,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: amountColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          Text(
                            category,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            date,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                      if (noteText != null && noteText.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          noteText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: amountColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            amountText,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: amountColor,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isIncome ? "收礼" : "随礼",
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: amountColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: "修改金额",
                      visualDensity: VisualDensity.compact,
                      color: amountColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    return recordOccasionFromLabel(category)?.icon ?? Icons.event;
  }
}
