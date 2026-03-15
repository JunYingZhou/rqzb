import "package:flutter/material.dart";
import "../data/isar_db.dart";
import "../data/renqing_record.dart";

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({super.key});

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _occasionController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = "收礼";
  String _relationship = "朋友";
  DateTime _date = DateTime.now();

  static const _relationshipOptions = [
    "家人",
    "亲戚",
    "朋友",
    "同事",
    "同学",
    "邻里",
    "其他",
  ];

  static const _occasionOptions = [
    "婚礼",
    "满月",
    "乔迁",
    "寿宴",
    "升学",
    "开业",
    "白事",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _occasionController.dispose();
    _relationshipController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2010),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _saveRecord() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amountValue = int.parse(_amountController.text.trim());
    final normalizedAmount = _type == "收礼" ? amountValue : -amountValue;
    final relationshipNote = _relationship == "其他"
        ? _relationshipController.text.trim()
        : null;

    final record = RenqingRecord()
      ..type = _type
      ..name = _nameController.text.trim()
      ..relationship = _relationship
      ..relationshipNote =
          relationshipNote?.isEmpty == true ? null : relationshipNote
      ..occasion = _occasionController.text.trim()
      ..amount = normalizedAmount
      ..date = _date
      ..note = _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim()
      ..createdAt = DateTime.now();

    await RecordRepository.add(record);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "新增记录",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _saveRecord,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "保存",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "记录类型",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: "收礼",
                        label: Text(
                          "收礼",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        icon: Icon(Icons.call_received, size: 18),
                      ),
                      ButtonSegment(
                        value: "随礼",
                        label: Text(
                          "随礼",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        icon: Icon(Icons.call_made, size: 18),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (value) {
                      setState(() => _type = value.first);
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _FormSection(
                  title: "基本信息",
                  child: Column(
                    children: [
                      _EnhancedTextFormField(
                        controller: _nameController,
                        labelText: "对象姓名",
                        hintText: "例如：张小兰",
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "请输入姓名";
                          }
                          return null;
                        },
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _EnhancedDropdownFormField<String>(
                        value: _relationship,
                        labelText: "关系",
                        items: _relationshipOptions
                            .map(
                              (option) => DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _relationship = value);
                          if (value != "其他") {
                            _relationshipController.clear();
                          }
                        },
                      ),
                      if (_relationship == "其他") ...[
                        const SizedBox(height: 12),
                        _EnhancedTextFormField(
                          controller: _relationshipController,
                          labelText: "关系补充",
                          hintText: "例如：客户/伙伴",
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (_relationship == "其他" &&
                                (value == null || value.trim().isEmpty)) {
                              return "请输入关系补充";
                            }
                            return null;
                          },
                          prefixIcon: Icons.group_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _FormSection(
                  title: "场合设置",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "常用场合",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B5A60),
                            ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _occasionOptions
                              .map(
                                (option) => _EnhancedChoiceChip(
                                  label: option,
                                  selected: _occasionController.text == option,
                                  onSelected: (selected) {
                                    setState(() {
                                      _occasionController.text =
                                          selected ? option : "";
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _EnhancedTextFormField(
                        controller: _occasionController,
                        labelText: "场合",
                        hintText: "例如：婚礼/满月",
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "请输入场合";
                          }
                          return null;
                        },
                        prefixIcon: Icons.event_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _FormSection(
                  title: "金额与日期",
                  child: Column(
                    children: [
                      _EnhancedTextFormField(
                        controller: _amountController,
                        labelText: "金额",
                        hintText: "例如：200",
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "请输入金额";
                          }
                          final amount = int.tryParse(value.trim());
                          if (amount == null || amount <= 0) {
                            return "金额需要是正整数";
                          }
                          return null;
                        },
                        prefixIcon: Icons.attach_money,
                        suffixText: "元",
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: Color(0xFF6B5A60),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "日期",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: const Color(0xFF6B5A60),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${_date.year}-${_date.month.toString().padLeft(2, "0")}-${_date.day.toString().padLeft(2, "0")}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Color(0xFF6B5A60),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _EnhancedTextFormField(
                        controller: _noteController,
                        labelText: "备注",
                        hintText: "可选",
                        maxLines: 3,
                        prefixIcon: Icons.note_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saveRecord,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "保存记录",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Enhanced form widgets
class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _EnhancedTextFormField extends StatelessWidget {
  const _EnhancedTextFormField({
    required this.controller,
    required this.labelText,
    this.hintText,
    this.textInputAction,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixText,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final IconData? prefixIcon;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
          suffixText: suffixText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        textInputAction: textInputAction,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }
}

class _EnhancedDropdownFormField<T> extends StatelessWidget {
  const _EnhancedDropdownFormField({
    required this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final String labelText;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

class _EnhancedChoiceChip extends StatelessWidget {
  const _EnhancedChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF6B5A60),
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: selected,
        onSelected: onSelected,
        backgroundColor: Colors.grey.shade100,
        selectedColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

