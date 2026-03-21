import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:isar/isar.dart";

import "../data/isar_db.dart";
import "../data/person.dart";
import "../data/renqing_record.dart";
import "../theme/semantic_colors.dart";
import "../widgets/edit_record_amount_dialog.dart";
import "../widgets/shell_scaffold.dart";

// Heuristic index labels for Chinese names.
// We keep this local to the page so the rest of the app does not need to know
// about display-only grouping rules.
const Map<String, String> _compoundSurnameInitials = {
  "欧阳": "O",
  "司马": "S",
  "上官": "S",
  "诸葛": "Z",
  "司徒": "S",
  "夏侯": "X",
  "拓跋": "T",
  "端木": "D",
  "独孤": "D",
  "南宫": "N",
  "长孙": "C",
  "尉迟": "Y",
  "令狐": "L",
  "慕容": "M",
  "宇文": "Y",
  "闻人": "W",
  "皇甫": "H",
  "公孙": "G",
  "仲孙": "Z",
  "轩辕": "X",
  "百里": "B",
  "东郭": "D",
  "西门": "X",
  "申屠": "S",
  "公羊": "G",
  "羊舌": "Y",
  "漆雕": "Q",
  "壤驷": "R",
  "公冶": "G",
  "宗政": "Z",
  "濮阳": "P",
  "淳于": "C",
  "单于": "C",
  "太叔": "T",
  "公良": "G",
  "仲长": "Z",
  "子书": "Z",
  "子桑": "Z",
  "即墨": "J",
  "达奚": "D",
  "褚师": "C",
  "谷梁": "G",
};

const Map<String, String> _singleCharacterInitials = {
  "阿": "A",
  "艾": "A",
  "安": "A",
  "敖": "A",
  "巴": "B",
  "白": "B",
  "鲍": "B",
  "毕": "B",
  "卞": "B",
  "蔡": "C",
  "曹": "C",
  "岑": "C",
  "常": "C",
  "陈": "C",
  "成": "C",
  "程": "C",
  "崔": "C",
  "戴": "D",
  "单": "D",
  "邓": "D",
  "丁": "D",
  "董": "D",
  "杜": "D",
  "段": "D",
  "樊": "F",
  "范": "F",
  "方": "F",
  "冯": "F",
  "傅": "F",
  "甘": "G",
  "高": "G",
  "葛": "G",
  "龚": "G",
  "谷": "G",
  "顾": "G",
  "郭": "G",
  "韩": "H",
  "何": "H",
  "贺": "H",
  "洪": "H",
  "侯": "H",
  "胡": "H",
  "黄": "H",
  "贾": "J",
  "姜": "J",
  "江": "J",
  "金": "J",
  "康": "K",
  "柯": "K",
  "孔": "K",
  "赖": "L",
  "蓝": "L",
  "雷": "L",
  "黎": "L",
  "李": "L",
  "梁": "L",
  "林": "L",
  "刘": "L",
  "柳": "L",
  "卢": "L",
  "陆": "L",
  "罗": "L",
  "吕": "L",
  "马": "M",
  "毛": "M",
  "孟": "M",
  "莫": "M",
  "倪": "N",
  "宁": "N",
  "欧": "O",
  "彭": "P",
  "钱": "Q",
  "秦": "Q",
  "邱": "Q",
  "丘": "Q",
  "任": "R",
  "饶": "R",
  "沈": "S",
  "宋": "S",
  "孙": "S",
  "谭": "T",
  "唐": "T",
  "田": "T",
  "童": "T",
  "汪": "W",
  "王": "W",
  "韦": "W",
  "魏": "W",
  "吴": "W",
  "武": "W",
  "夏": "X",
  "萧": "X",
  "肖": "X",
  "谢": "X",
  "徐": "X",
  "许": "X",
  "薛": "X",
  "严": "Y",
  "颜": "Y",
  "杨": "Y",
  "姚": "Y",
  "叶": "Y",
  "尹": "Y",
  "于": "Y",
  "余": "Y",
  "袁": "Y",
  "岳": "Y",
  "曾": "Z",
  "翟": "Z",
  "詹": "Z",
  "张": "Z",
  "赵": "Z",
  "郑": "Z",
  "周": "Z",
  "朱": "Z",
  "庄": "Z",
  "宗": "Z",
  "左": "Z",
  "小": "X",
  "大": "D",
  "老": "L",
};

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<Id> _selectedIds = <Id>{};
  final Map<String, GlobalKey> _sectionKeys = <String, GlobalKey>{};
  String _query = "";

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showAddContactDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => _AddContactDialog(
        onSaved: _showSnackBar,
      ),
    );
  }

  Future<void> _showContactDetails(Person person) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ContactDetailSheet(person: person),
    );
  }

  Future<void> _deleteSelectedContacts() async {
    if (_selectedIds.isEmpty) {
      _showSnackBar("请先长按或点选联系人后再删除");
      return;
    }

    final selectedIds = _selectedIds.toList(growable: false);
    final preview = await PersonRepository.previewDeleteByIds(selectedIds);
    if (!mounted) return;

    if (preview.contactCount == 0) {
      setState(() => _selectedIds.clear());
      _showSnackBar("未找到可删除的联系人");
      return;
    }

    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("删除联系人及关联记录"),
              content: Text(_buildDeletePreviewMessage(preview)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("取消"),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("删除"),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete) return;

    await PersonRepository.deleteByIds(selectedIds);
    if (!mounted) return;
    setState(_selectedIds.clear);
    _showSnackBar(
      preview.totalRelatedRecordCount > 0 ? "联系人及关联记录已删除" : "联系人已删除",
    );
  }

  String _buildDeletePreviewMessage(ContactDeletePreview preview) {
    final buffer = StringBuffer(
      "确定删除已选中的 ${preview.contactCount} 位联系人吗？",
    );

    if (preview.totalRelatedRecordCount == 0) {
      buffer.write("\n\n此操作不可撤销。");
      return buffer.toString();
    }

    final detailParts = <String>[];
    if (preview.renqingRecordCount > 0) {
      detailParts.add("往来记录 ${preview.renqingRecordCount} 条");
    }
    if (preview.giftRecordCount > 0) {
      detailParts.add("礼簿记录 ${preview.giftRecordCount} 条");
    }

    buffer
      ..write("\n\n")
      ..write("删除后会同时清除该联系人的全部信息记录，共 ")
      ..write(preview.totalRelatedRecordCount)
      ..write(" 条")
      ..write(detailParts.isEmpty ? "" : "（${detailParts.join("，")}）")
      ..write("，且无法恢复。");

    return buffer.toString();
  }

  void _toggleSelection(Id id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _scrollToSection(String label) {
    final key = _sectionKeys[label];
    if (key == null || !_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final targetContext = key.currentContext;
      if (targetContext == null) return;

      final renderObject = targetContext.findRenderObject();
      if (renderObject is! RenderObject || !renderObject.attached) return;

      final viewport = RenderAbstractViewport.maybeOf(renderObject);
      if (viewport == null) return;

      final targetOffset = viewport.getOffsetToReveal(renderObject, 0).offset;
      final position = _scrollController.position;
      final safeOffset = targetOffset.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );

      position.animateTo(
        safeOffset,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
      );
    });
  }

  List<Person> _filterAndSort(List<Person> persons) {
    final query = _query.trim().toLowerCase();
    final filtered = persons.where((person) {
      if (query.isEmpty) return true;
      final relation = person.relation?.toLowerCase() ?? "";
      final phone = person.phone?.toLowerCase() ?? "";
      final note = person.note?.toLowerCase() ?? "";
      return person.name.toLowerCase().contains(query) ||
          relation.contains(query) ||
          phone.contains(query) ||
          note.contains(query);
    }).toList();

    filtered.sort((a, b) {
      final aLabel = _sectionLabelFor(a.name);
      final bLabel = _sectionLabelFor(b.name);
      if (aLabel == bLabel) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      if (aLabel == "#") return 1;
      if (bLabel == "#") return -1;
      return aLabel.compareTo(bLabel);
    });
    return filtered;
  }

  List<_ContactSection> _buildSections(List<Person> persons) {
    final sections = <_ContactSection>[];
    for (final person in persons) {
      final label = _sectionLabelFor(person.name);
      if (sections.isEmpty || sections.last.label != label) {
        sections.add(_ContactSection(label: label, persons: <Person>[person]));
      } else {
        sections.last.persons.add(person);
      }
    }

    for (final section in sections) {
      _sectionKeys.putIfAbsent(section.label, GlobalKey.new);
    }
    _sectionKeys.removeWhere(
      (label, _) => !sections.any((section) => section.label == label),
    );
    return sections;
  }

  String _sectionLabelFor(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty) return "#";

    final compoundInitial = _compoundSurnameInitial(normalized);
    if (compoundInitial != null) {
      return compoundInitial;
    }

    final seed = _firstIndexSeed(normalized);
    if (seed == null) return "#";

    final rune = seed.runes.first;
    if (_isAsciiLetter(rune)) {
      return String.fromCharCode(rune).toUpperCase();
    }
    if (_isDigit(rune)) {
      return "#";
    }

    return _singleCharacterInitials[seed] ?? "#";
  }

  String? _compoundSurnameInitial(String normalizedName) {
    for (final entry in _compoundSurnameInitials.entries) {
      if (normalizedName.startsWith(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  String? _firstIndexSeed(String text) {
    for (final rune in text.runes) {
      if (_isAsciiLetter(rune) || _isDigit(rune) || _isChineseIdeograph(rune)) {
        return String.fromCharCode(rune);
      }
    }
    return null;
  }

  bool _isAsciiLetter(int rune) {
    return (rune >= 65 && rune <= 90) || (rune >= 97 && rune <= 122);
  }

  bool _isDigit(int rune) {
    return rune >= 48 && rune <= 57;
  }

  bool _isChineseIdeograph(int rune) {
    return (rune >= 0x4E00 && rune <= 0x9FFF) ||
        (rune >= 0x3400 && rune <= 0x4DBF) ||
        (rune >= 0xF900 && rune <= 0xFAFF) ||
        (rune >= 0x20000 && rune <= 0x2A6DF) ||
        (rune >= 0x2A700 && rune <= 0x2B73F) ||
        (rune >= 0x2B740 && rune <= 0x2B81F) ||
        (rune >= 0x2B820 && rune <= 0x2CEAF) ||
        (rune >= 0x2F800 && rune <= 0x2FA1F);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Person>>(
      stream: PersonRepository.watchAll(),
      builder: (context, snapshot) {
        final persons = _filterAndSort(snapshot.data ?? const <Person>[]);
        final sections = _buildSections(persons);
        final labels = sections.map((section) => section.label).toList();

        return ShellScaffold(
          currentIndex: 1,
          child: SafeArea(
            child: Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      title: Text(
                        _selectedIds.isEmpty
                            ? "联系人"
                            : "已选择 ${_selectedIds.length} 位联系人",
                      ),
                      actions: [
                        IconButton(
                          onPressed: _deleteSelectedContacts,
                          icon: Icon(
                            Icons.delete_outline,
                            color: _selectedIds.isEmpty
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.45)
                                : null,
                          ),
                          tooltip: "删除联系人",
                        ),
                        IconButton(
                          onPressed: _showAddContactDialog,
                          icon: const Icon(Icons.person_add_alt_1),
                          tooltip: "添加联系人",
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          decoration: InputDecoration(
                            hintText: "搜索姓名、关系、电话或备注",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = "");
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    if (persons.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 52,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.7),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _query.isEmpty ? "还没有联系人" : "没有匹配的联系人",
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _query.isEmpty
                                      ? "点击右上角加号，先把常用联系人存起来。"
                                      : "换个关键词试试，或者清空搜索条件。",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 36, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final section = sections[index];
                              return _ContactSectionView(
                                key: _sectionKeys[section.label],
                                section: section,
                                selectedIds: _selectedIds,
                                onToggleSelection: _toggleSelection,
                                onShowDetails: _showContactDetails,
                              );
                            },
                            childCount: sections.length,
                          ),
                        ),
                      ),
                  ],
                ),
                if (labels.isNotEmpty)
                  Positioned(
                    top: 156,
                    right: 4,
                    bottom: 28,
                    child: _AlphabetIndexBar(
                      labels: labels,
                      onSelect: _scrollToSection,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AddContactDialog extends StatefulWidget {
  const _AddContactDialog({
    required this.onSaved,
  });

  final ValueChanged<String> onSaved;

  @override
  State<_AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<_AddContactDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请先输入联系人姓名")),
      );
      return;
    }

    final person = Person()
      ..name = name
      ..relation = _nullableText(_relationController.text)
      ..phone = _nullableText(_phoneController.text)
      ..note = _nullableText(_noteController.text);

    await PersonRepository.add(person);
    if (!mounted) return;

    Navigator.of(context).pop();
    widget.onSaved("联系人已添加");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("添加联系人"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: "姓名",
                hintText: "请输入联系人姓名",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _relationController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: "关系",
                hintText: "同事 / 朋友 / 亲戚",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "电话",
                hintText: "请输入手机号或电话",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "备注",
                hintText: "补充说明",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("取消"),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text("保存"),
        ),
      ],
    );
  }

  String? _nullableText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _ContactSection {
  _ContactSection({
    required this.label,
    required this.persons,
  });

  final String label;
  final List<Person> persons;
}

class _ContactSectionView extends StatelessWidget {
  const _ContactSectionView({
    super.key,
    required this.section,
    required this.selectedIds,
    required this.onToggleSelection,
    required this.onShowDetails,
  });

  final _ContactSection section;
  final Set<Id> selectedIds;
  final ValueChanged<Id> onToggleSelection;
  final ValueChanged<Person> onShowDetails;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          child: Text(
            section.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        ...section.persons.map((person) {
          final isSelected = selectedIds.contains(person.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onLongPress: () => onToggleSelection(person.id),
                onTap: () {
                  if (selectedIds.isNotEmpty) {
                    onToggleSelection(person.id);
                    return;
                  }

                  onShowDetails(person);
                },
                child: Ink(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.55)
                        : Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withValues(alpha: 0.35),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.12),
                          child: Text(
                            _avatarText(person.name),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      person.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (person.relation != null)
                                    _MetaChip(text: person.relation!),
                                  if (person.phone != null)
                                    _MetaChip(text: person.phone!),
                                ],
                              ),
                              if (person.note != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  person.note!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  String _avatarText(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return "?";
    return trimmed[0].toUpperCase();
  }
}

enum _RecordRange {
  all("全部"),
  recentOneYear("近一年"),
  recentTwoYears("近两年");

  const _RecordRange(this.label);

  final String label;
}

class _ContactDetailSheet extends StatefulWidget {
  const _ContactDetailSheet({
    required this.person,
  });

  final Person person;

  @override
  State<_ContactDetailSheet> createState() => _ContactDetailSheetState();
}

class _ContactDetailSheetState extends State<_ContactDetailSheet> {
  _RecordRange _selectedRange = _RecordRange.all;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: StreamBuilder<List<RenqingRecord>>(
          stream: RecordRepository.watchByName(widget.person.name),
          builder: (context, snapshot) {
            final allRecords = snapshot.data ?? const <RenqingRecord>[];
            final records = _filterRecords(allRecords, _selectedRange);
            final sentTotal = records
                .where((record) => record.amount < 0)
                .fold<int>(0, (sum, record) => sum + record.amount.abs());
            final receivedTotal = records
                .where((record) => record.amount > 0)
                .fold<int>(0, (sum, record) => sum + record.amount);
            final theyOweMe =
                sentTotal > receivedTotal ? sentTotal - receivedTotal : 0;
            final iOweThem =
                receivedTotal > sentTotal ? receivedTotal - sentTotal : 0;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          _avatarText(widget.person.name),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.person.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (widget.person.relation != null)
                                  _MetaChip(text: widget.person.relation!),
                                if (widget.person.phone != null)
                                  _MetaChip(text: widget.person.phone!),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.person.note != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.person.note!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    "往来范围",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _RecordRange.values.map((range) {
                      final isSelected = range == _selectedRange;
                      return ChoiceChip(
                        label: Text(range.label),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedRange = range);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: "他差我多少",
                          amount: theyOweMe,
                          tint: receivedSemanticColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: "我差他多少",
                          amount: iOweThem,
                          tint: sentSemanticColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: "我随礼合计",
                          amount: sentTotal,
                          tint: sentSemanticColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: "我收礼合计",
                          amount: receivedTotal,
                          tint: receivedSemanticColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "往来记录",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (records.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        "当前范围内还没有往来记录",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ...records.map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RecordHistoryCard(
                          record: record,
                          onEdit: () => _editRecordAmount(record),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<RenqingRecord> _filterRecords(
    List<RenqingRecord> records,
    _RecordRange range,
  ) {
    if (range == _RecordRange.all) {
      return records;
    }

    final now = DateTime.now();
    final start = range == _RecordRange.recentOneYear
        ? DateTime(now.year - 1, now.month, now.day)
        : DateTime(now.year - 2, now.month, now.day);

    return records.where((record) => !record.date.isBefore(start)).toList();
  }

  String _avatarText(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return "?";
    return trimmed[0].toUpperCase();
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.tint,
  });

  final String title;
  final int amount;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tint.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "￥$amount",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: tint,
                  fontWeight: FontWeight.w800,
                ),
          ),
          /* IconButton(
            onPressed: null,
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: "修改金额",
            visualDensity: VisualDensity.compact,
            color: tint,
          ), */
        ],
      ),
    );
  }
}

class _RecordHistoryCard extends StatelessWidget {
  const _RecordHistoryCard({
    required this.record,
    required this.onEdit,
  });

  final RenqingRecord record;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final isReceived = record.amount > 0;
    final tint = isReceived ? receivedSemanticColor : sentSemanticColor;
    final tagText = isReceived ? "收礼" : "随礼";

    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                tagText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tint,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.occasion,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(record.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  if (record.note != null &&
                      record.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      record.note!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${isReceived ? "+" : "-"}￥${record.amount.abs()}",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tint,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _AlphabetIndexBar extends StatelessWidget {
  const _AlphabetIndexBar({
    required this.labels,
    required this.onSelect,
  });

  final List<String> labels;
  final ValueChanged<String> onSelect;

  void _handlePosition(BoxConstraints constraints, double dy) {
    if (labels.isEmpty) return;
    final itemExtent = constraints.maxHeight / labels.length;
    final index = (dy / itemExtent).floor().clamp(0, labels.length - 1);
    onSelect(labels[index]);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) =>
              _handlePosition(constraints, details.localPosition.dy),
          onVerticalDragStart: (details) =>
              _handlePosition(constraints, details.localPosition.dy),
          onVerticalDragUpdate: (details) =>
              _handlePosition(constraints, details.localPosition.dy),
          child: Container(
            width: 28,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels
                  .map(
                    (label) => Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
