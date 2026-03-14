import "package:flutter/material.dart";

void main() {
  runApp(const RenqingLedgerApp());
}

class RenqingLedgerApp extends StatelessWidget {
  const RenqingLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFFD31145);

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brand,
        primary: brand,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F4F6),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF7F4F6),
        foregroundColor: Color(0xFF1B0A0F),
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );

    return MaterialApp(
      title: "人情账本",
      theme: theme,
      home: const RootShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const RecordPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: "记录",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "我的",
          ),
        ],
      ),
    );
  }
}

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
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
                    "本季度概览",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: "收礼",
                          value: "¥2,680",
                          highlight: colorScheme.primaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: "随礼",
                          value: "¥1,920",
                          highlight: colorScheme.secondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _QuickActions(
                    onAdd: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddRecordPage(),
                        ),
                      );
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
                  name: "张小兰",
                  category: "婚礼",
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
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.highlight,
  });

  final String label;
  final String value;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B5A60),
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF1B0A0F),
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: highlight,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text("新增记录"),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: onImport,
              icon: const Icon(Icons.file_upload),
              tooltip: "导入",
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: onExport,
              icon: const Icon(Icons.file_download),
              tooltip: "导出",
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.name,
    required this.category,
    required this.date,
    required this.amount,
  });

  final String name;
  final String category;
  final String date;
  final int amount;

  @override
  Widget build(BuildContext context) {
    final isIncome = amount >= 0;
    final amountText = "${isIncome ? "+" : "-"}¥${amount.abs()}";
    final amountColor = isIncome
        ? const Color(0xFF198754)
        : const Color(0xFFB02A37);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text("$category · $date"),
        trailing: Text(
          amountText,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: amountColor),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text("我的"),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: _ProfileHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text(
                "季度统计",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _QuarterTable(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                "年度统计",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _YearTable(),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.person, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "张小兰",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "常用手机号：138****8821",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B5A60),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "当前位置：上海",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B5A60),
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit),
              tooltip: "编辑资料",
            ),
          ],
        ),
      ),
    );
  }
}

class _QuarterTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rows = [
      _TableRowData("2026 Q1", 2680, 1920, 760),
      _TableRowData("2025 Q4", 4220, 2510, 1710),
      _TableRowData("2025 Q3", 3180, 2090, 1090),
    ];

    return _StatTable(rows: rows);
  }
}

class _YearTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rows = [
      _TableRowData("2026", 2680, 1920, 760),
      _TableRowData("2025", 14200, 9250, 4950),
      _TableRowData("2024", 11680, 8420, 3260),
    ];

    return _StatTable(rows: rows);
  }
}

class _TableRowData {
  const _TableRowData(this.period, this.income, this.expense, this.balance);

  final String period;
  final int income;
  final int expense;
  final int balance;
}

class _StatTable extends StatelessWidget {
  const _StatTable({required this.rows});

  final List<_TableRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(child: Text("周期")),
                Expanded(child: Text("收礼")),
                Expanded(child: Text("随礼")),
                Expanded(child: Text("结余")),
              ],
            ),
            const Divider(height: 20),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(row.period)),
                    Expanded(child: Text("¥${row.income}")),
                    Expanded(child: Text("¥${row.expense}")),
                    Expanded(
                      child: Text(
                        "¥${row.balance}",
                        style: TextStyle(
                          color: row.balance >= 0
                              ? const Color(0xFF198754)
                              : const Color(0xFFB02A37),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({super.key});

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _occasionController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = "收礼";
  DateTime _date = DateTime(2026, 3, 15);

  @override
  void dispose() {
    _nameController.dispose();
    _occasionController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("新增记录"),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop();
              }
            },
            child: const Text("保存"),
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: "收礼", label: Text("收礼")),
                    ButtonSegment(value: "随礼", label: Text("随礼")),
                  ],
                  selected: {_type},
                  onSelectionChanged: (value) {
                    setState(() => _type = value.first);
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "对象姓名",
                    hintText: "例如：张小兰",
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "请输入姓名";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _occasionController,
                  decoration: const InputDecoration(
                    labelText: "场合",
                    hintText: "例如：婚礼 / 满月",
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "请输入场合";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: "金额",
                    hintText: "例如：500",
                  ),
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
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "日期",
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "${_date.year}-${_date.month.toString().padLeft(2, "0")}-${_date.day.toString().padLeft(2, "0")}",
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: "备注",
                    hintText: "可选",
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("保存记录"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
