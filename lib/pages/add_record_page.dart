import "package:flutter/material.dart";

import "../data/isar_db.dart";
import "../data/person.dart";
import "../data/record_occasion.dart";
import "../data/renqing_record.dart";

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({super.key});

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  final _manualNameController = TextEditingController();
  final _manualRelationController = TextEditingController();
  final _manualPhoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = "收礼";
  DateTime _date = DateTime.now();
  bool _isManualEntry = false;
  bool _showOccasionError = false;
  Person? _selectedPerson;
  RecordOccasion? _selectedOccasion;

  @override
  void dispose() {
    _contactController.dispose();
    _manualNameController.dispose();
    _manualRelationController.dispose();
    _manualPhoneController.dispose();
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
    final selectedOccasion = _selectedOccasion;
    if (selectedOccasion == null) {
      setState(() => _showOccasionError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请选择场合")),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amountValue = int.parse(_amountController.text.trim());
    final normalizedAmount = _type == "收礼" ? amountValue : -amountValue;
    final record = RenqingRecord()
      ..type = _type
      ..occasion = selectedOccasion.label
      ..amount = normalizedAmount
      ..date = _date
      ..note = _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim()
      ..createdAt = DateTime.now();

    if (_isManualEntry) {
      final name = _manualNameController.text.trim();
      final relation = _manualRelationController.text.trim();
      final phone = _manualPhoneController.text.trim();

      record
        ..name = name
        ..relationship = relation
        ..relationshipNote = null;

      final existingPerson = await PersonRepository.findByName(name);
      if (existingPerson == null) {
        final person = Person()
          ..name = name
          ..relation = relation
          ..phone = phone.isEmpty ? null : phone;
        await PersonRepository.add(person);
      }
    } else {
      final selectedPerson = _selectedPerson;
      if (selectedPerson == null) return;

      record
        ..name = selectedPerson.name.trim()
        ..relationship = (selectedPerson.relation ?? "").trim()
        ..relationshipNote = null;
    }

    await RecordRepository.add(record);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final surfaceCard = colorScheme.surfaceContainerHighest;
    final subtleShadow = BoxShadow(
      color: colorScheme.shadow.withValues(alpha: isDark ? 0.28 : 0.08),
      blurRadius: 10,
      offset: const Offset(0, 3),
    );

    return StreamBuilder<List<Person>>(
      stream: PersonRepository.watchAll(),
      builder: (context, snapshot) {
        final persons = snapshot.data ?? const <Person>[];

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [subtleShadow],
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
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (states) {
                              if (states.contains(WidgetState.selected)) {
                                return colorScheme.primaryContainer;
                              }
                              return surfaceCard;
                            },
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith(
                            (states) {
                              if (states.contains(WidgetState.selected)) {
                                return colorScheme.onPrimaryContainer;
                              }
                              return colorScheme.onSurfaceVariant;
                            },
                          ),
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
                      title: "人员信息",
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: surfaceCard,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [subtleShadow],
                            ),
                            child: SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment<bool>(
                                  value: false,
                                  label: Text("从联系人选择"),
                                  icon: Icon(Icons.people_outline, size: 18),
                                ),
                                ButtonSegment<bool>(
                                  value: true,
                                  label: Text("联系人中没有"),
                                  icon: Icon(Icons.person_add_alt_1, size: 18),
                                ),
                              ],
                              selected: {_isManualEntry},
                              onSelectionChanged: (value) {
                                setState(() {
                                  _isManualEntry = value.first;
                                  if (_isManualEntry) {
                                    _selectedPerson = null;
                                    _contactController.clear();
                                  } else {
                                    _manualNameController.clear();
                                    _manualRelationController.clear();
                                    _manualPhoneController.clear();
                                  }
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.resolveWith(
                                  (states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return colorScheme.primaryContainer;
                                    }
                                    return surfaceCard;
                                  },
                                ),
                                foregroundColor: WidgetStateProperty.resolveWith(
                                  (states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return colorScheme.onPrimaryContainer;
                                    }
                                    return colorScheme.onSurfaceVariant;
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_isManualEntry) ...[
                            _EnhancedTextFormField(
                              controller: _manualNameController,
                              labelText: "姓名",
                              hintText: "联系人中没有时可直接填写",
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (_isManualEntry &&
                                    (value == null || value.trim().isEmpty)) {
                                  return "请输入姓名";
                                }
                                return null;
                              },
                              prefixIcon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                            _EnhancedTextFormField(
                              controller: _manualRelationController,
                              labelText: "关系",
                              hintText: "例如：朋友 / 亲戚 / 同事",
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (_isManualEntry &&
                                    (value == null || value.trim().isEmpty)) {
                                  return "请输入关系";
                                }
                                return null;
                              },
                              prefixIcon: Icons.group_outlined,
                            ),
                            const SizedBox(height: 16),
                            _EnhancedTextFormField(
                              controller: _manualPhoneController,
                              labelText: "电话",
                              hintText: "可选，保存时会自动加入联系人",
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_outlined,
                            ),
                          ] else ...[
                            _ContactSelectorField(
                              persons: persons,
                              controller: _contactController,
                              selectedPerson: _selectedPerson,
                              onSelected: (person) {
                                setState(() {
                                  _selectedPerson = person;
                                  _contactController.text = person.name;
                                });
                              },
                              validator: () {
                                if (!_isManualEntry && _selectedPerson == null) {
                                  return "请先从联系人中选择人员";
                                }
                                return null;
                              },
                              onCleared: () {
                                setState(() {
                                  _selectedPerson = null;
                                  _contactController.clear();
                                });
                              },
                            ),
                            if (_selectedPerson != null) ...[
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if ((_selectedPerson!.relation ?? "")
                                        .trim()
                                        .isNotEmpty)
                                      _SelectedInfoChip(
                                        icon: Icons.group_outlined,
                                        text:
                                            _selectedPerson!.relation!.trim(),
                                      ),
                                    if ((_selectedPerson!.phone ?? "")
                                        .trim()
                                        .isNotEmpty)
                                      _SelectedInfoChip(
                                        icon: Icons.phone_outlined,
                                        text: _selectedPerson!.phone!.trim(),
                                      ),
                                  ],
                                ),
                              ),
                            ],
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
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: surfaceCard,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [subtleShadow],
                            ),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: RecordOccasion.values
                                  .map(
                                    (option) => _EnhancedChoiceChip(
                                      label: option.label,
                                      selected: _selectedOccasion == option,
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedOccasion =
                                              selected ? option : null;
                                          _showOccasionError = false;
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          if (_showOccasionError) ...[
                            const SizedBox(height: 12),
                            Text(
                              "请选择场合",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          ],
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
                                color: surfaceCard,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [subtleShadow],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "日期",
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${_date.year}-${_date.month.toString().padLeft(2, "0")}-${_date.day.toString().padLeft(2, "0")}",
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant,
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
      },
    );
  }
}

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final fieldColor = colorScheme.surfaceContainerHighest;
    final shadow = BoxShadow(
      color: colorScheme.shadow.withValues(alpha: isDark ? 0.28 : 0.08),
      blurRadius: 10,
      offset: const Offset(0, 3),
    );

    return Container(
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [shadow],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                )
              : null,
          suffixText: suffixText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: fieldColor,
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

class _ContactSelectorField extends FormField<Person> {
  _ContactSelectorField({
    required List<Person> persons,
    required TextEditingController controller,
    required Person? selectedPerson,
    required ValueChanged<Person> onSelected,
    required String? Function() validator,
    required VoidCallback onCleared,
  }) : super(
          validator: (_) => validator(),
          builder: (field) {
            final theme = Theme.of(field.context);
            final colorScheme = theme.colorScheme;
            final isDark = theme.brightness == Brightness.dark;
            final fieldColor = colorScheme.surfaceContainerHighest;
            final shadow = BoxShadow(
              color: colorScheme.shadow.withValues(alpha: isDark ? 0.28 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: fieldColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [shadow],
                  ),
                  child: Autocomplete<Person>(
                    displayStringForOption: (option) => option.name,
                    optionsBuilder: (textEditingValue) {
                      final query = textEditingValue.text.trim().toLowerCase();
                      if (query.isEmpty) {
                        return persons;
                      }

                      return persons.where((person) {
                        final relation = person.relation?.toLowerCase() ?? "";
                        final phone = person.phone?.toLowerCase() ?? "";
                        return person.name.toLowerCase().contains(query) ||
                            relation.contains(query) ||
                            phone.contains(query);
                      });
                    },
                    onSelected: (person) {
                      controller.text = person.name;
                      onSelected(person);
                      field.didChange(person);
                    },
                    fieldViewBuilder:
                        (context, textController, focusNode, onFieldSubmitted) {
                      if (textController.text != controller.text) {
                        textController.value = controller.value;
                      }

                      return TextFormField(
                        controller: textController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: "联系人",
                          hintText: "搜索并选择联系人",
                          prefixIcon: Icon(
                            Icons.people_outline,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          suffixIcon: selectedPerson == null
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    field.didChange(null);
                                    onCleared();
                                    textController.clear();
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                          errorText: field.errorText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: fieldColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (_) {
                          if (selectedPerson != null) {
                            field.didChange(null);
                            onCleared();
                          }
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelect, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(16),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 520,
                              maxHeight: 280,
                            ),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final person = options.elementAt(index);
                                final relation =
                                    (person.relation ?? "").trim();
                                final phone = (person.phone ?? "").trim();
                                final subtitle = [
                                  if (relation.isNotEmpty) relation,
                                  if (phone.isNotEmpty) phone,
                                ].join(" · ");

                                return ListTile(
                                  title: Text(person.name),
                                  subtitle: subtitle.isEmpty
                                      ? null
                                      : Text(subtitle),
                                  onTap: () => onSelect(person),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (persons.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    "当前还没有联系人，请切换到“联系人中没有”后直接填写。",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            );
          },
        );
}

class _SelectedInfoChip extends StatelessWidget {
  const _SelectedInfoChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: selected,
        onSelected: onSelected,
        backgroundColor: colorScheme.surfaceContainerHigh,
        selectedColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
