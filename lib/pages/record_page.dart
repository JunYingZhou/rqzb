import "dart:io";

import "package:flutter/material.dart";
import "package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart";
import "package:image_cropper/image_cropper.dart";
import "package:image_picker/image_picker.dart";
import "../routes.dart";
import "../widgets/shell_scaffold.dart";

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
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
        return AlertDialog(
          title: const Text("OCR识别结果"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ShellScaffold(
      currentIndex: 0,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : _showPickOptions,
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
                            value: "￥2,680",
                            highlight: colorScheme.primaryContainer,
                            icon: Icons.call_received,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: "随礼",
                            value: "￥1,920",
                            highlight: colorScheme.secondaryContainer,
                            icon: Icons.call_made,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _QuickActions(
                      onAdd: () {
                        Navigator.of(context).pushNamed(AppRoutes.addRecord);
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Text(
                  "最近记录",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            SliverList.separated(
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _RecordTile(
                    name: "张小六",
                    category: "婚礼",
                    relationship: "朋友",
                    date: "2026-03-14",
                    amount: index.isEven ? 500 : -300,
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
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
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

class _RecordTile extends StatefulWidget {
  const _RecordTile({
    required this.name,
    required this.category,
    required this.relationship,
    required this.date,
    required this.amount,
  });

  final String name;
  final String category;
  final String relationship;
  final String date;
  final int amount;

  @override
  State<_RecordTile> createState() => _RecordTileState();
}

class _RecordTileState extends State<_RecordTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
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
    final isIncome = widget.amount >= 0;
    final amountText = "${isIncome ? "+" : "-"}￥${widget.amount.abs()}";
    final amountColor = isIncome
        ? const Color(0xFF198754)
        : const Color(0xFFB02A37);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedScale(
                scale: _isPressed ? 0.98 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Card(
                  elevation: _isPressed ? 4 : 1,
                  shadowColor: const Color(0x1A000000),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isIncome
                            ? const Color(0xFF198754).withValues(alpha: 0.1)
                            : const Color(0xFFB02A37).withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: amountColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getCategoryIcon(widget.category),
                              color: amountColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        widget.relationship,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: const Color(0xFF6B5A60),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.category,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: const Color(0xFF6B5A60),
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.date,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: const Color(0xFF6B5A60),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                amountText,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: amountColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Icon(
                                isIncome
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                color: amountColor,
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "婚礼":
        return Icons.favorite;
      case "满月":
        return Icons.child_care;
      case "乔迁":
        return Icons.home;
      case "寿宴":
        return Icons.cake;
      case "升学":
        return Icons.school;
      case "开业":
        return Icons.business;
      case "白事":
        return Icons.church;
      default:
        return Icons.event;
    }
  }
}