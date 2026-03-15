import "package:flutter/material.dart";

void main() {
  runApp(const RenqingLedgerApp());
}

class RenqingLedgerApp extends StatelessWidget {
  const RenqingLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFFD31145);

    // Enhanced color palette with better semantic colors
    const semanticColors = {
      'income': Color(0xFF198754), // Green for income
      'expense': Color(0xFFB02A37), // Red for expense
      'neutral': Color(0xFF6B5A60), // Neutral text
      'surface': Color(0xFFF7F4F6), // Background
      'onSurface': Color(0xFF1B0A0F), // Primary text
      'cardShadow': Color(0x0A000000), // Subtle shadow
    };

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brand,
        primary: brand,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: semanticColors['surface'],
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: semanticColors['surface'],
        foregroundColor: semanticColors['onSurface'],
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shadowColor: semanticColors['cardShadow'],
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: brand,
            width: 2,
          ),
        ),
        labelStyle: TextStyle(
          color: semanticColors['neutral'],
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: semanticColors['neutral']?.withValues(alpha: 0.7),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: semanticColors['cardShadow'],
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
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
                          icon: Icons.call_received,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: "随礼",
                          value: "¥1,920",
                          highlight: colorScheme.secondaryContainer,
                          icon: Icons.call_made,
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
    final amountText = "${isIncome ? "+" : "-"}¥${widget.amount.abs()}";
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
              child: Column(
                children: [
                  _QuarterChart(
                    rows: const [
                      _TableRowData("2026 Q1", 2680, 1920, 760),
                      _TableRowData("2025 Q4", 4220, 2510, 1710),
                      _TableRowData("2025 Q3", 3180, 2090, 1090),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _QuarterTable(),
                ],
              ),
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
              child: Column(
                children: [
                  _YearChart(
                    rows: const [
                      _TableRowData("2026", 2680, 1920, 760),
                      _TableRowData("2025", 14200, 9250, 4950),
                      _TableRowData("2024", 11680, 8420, 3260),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _YearTable(),
                ],
              ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
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
              colorScheme.primaryContainer.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "张小兰",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.phone,
                      text: "常用手机号：138****8821",
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(
                      icon: Icons.location_on,
                      text: "当前位置：上海",
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  tooltip: "编辑资料",
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF6B5A60),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B5A60),
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
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

class _QuarterChart extends StatelessWidget {
  const _QuarterChart({required this.rows});

  final List<_TableRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: const Color(0x0F000000),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          children: [
            _ChartLegend(
              items: const [
                _LegendItem(
                  label: "鏀剁ぜ",
                  color: Color(0xFF198754),
                ),
                _LegendItem(
                  label: "闅忕ぜ",
                  color: Color(0xFFB02A37),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: CustomPaint(
                painter: _GroupedBarChartPainter(
                  rows: rows,
                  incomeColor: const Color(0xFF198754),
                  expenseColor: const Color(0xFFB02A37),
                ),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: rows
                  .map(
                    (row) => Expanded(
                      child: Text(
                        row.period,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B5A60),
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
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

class _YearChart extends StatelessWidget {
  const _YearChart({required this.rows});

  final List<_TableRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: const Color(0x0F000000),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          children: [
            _ChartLegend(
              items: const [
                _LegendItem(
                  label: "缁撲綑",
                  color: Color(0xFF1B0A0F),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: CustomPaint(
                painter: _LineChartPainter(
                  rows: rows,
                  lineColor: const Color(0xFF1B0A0F),
                  pointFill: const Color(0xFFD31145),
                ),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: rows
                  .map(
                    (row) => Expanded(
                      child: Text(
                        row.period,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B5A60),
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableRowData {
  const _TableRowData(this.period, this.income, this.expense, this.balance);

  final String period;
  final int income;
  final int expense;
  final int balance;
}

class _LegendItem {
  const _LegendItem({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.items});

  final List<_LegendItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B5A60),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _GroupedBarChartPainter extends CustomPainter {
  _GroupedBarChartPainter({
    required this.rows,
    required this.incomeColor,
    required this.expenseColor,
  });

  final List<_TableRowData> rows;
  final Color incomeColor;
  final Color expenseColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (rows.isEmpty) return;

    final maxValue = rows
        .map((row) => row.income > row.expense ? row.income : row.expense)
        .reduce((a, b) => a > b ? a : b)
        .toDouble()
        .clamp(1, double.infinity);

    final chartPadding = const EdgeInsets.fromLTRB(8, 8, 8, 20);
    final chartWidth = size.width - chartPadding.horizontal;
    final chartHeight = size.height - chartPadding.vertical;

    final groupWidth = chartWidth / rows.length;
    final barWidth = groupWidth * 0.28;
    final barGap = groupWidth * 0.12;

    final baseY = chartPadding.top + chartHeight;
    final axisPaint = Paint()
      ..color = const Color(0x1A000000)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(chartPadding.left, baseY),
      Offset(chartPadding.left + chartWidth, baseY),
      axisPaint,
    );

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final centerX = chartPadding.left + groupWidth * (i + 0.5);

      final incomeHeight = (row.income / maxValue) * chartHeight;
      final expenseHeight = (row.expense / maxValue) * chartHeight;

      final incomeRect = Rect.fromLTWH(
        centerX - barWidth - barGap / 2,
        baseY - incomeHeight,
        barWidth,
        incomeHeight,
      );
      final expenseRect = Rect.fromLTWH(
        centerX + barGap / 2,
        baseY - expenseHeight,
        barWidth,
        expenseHeight,
      );

      final incomePaint = Paint()..color = incomeColor;
      final expensePaint = Paint()..color = expenseColor;

      canvas.drawRRect(
        RRect.fromRectAndRadius(incomeRect, const Radius.circular(6)),
        incomePaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(expenseRect, const Radius.circular(6)),
        expensePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GroupedBarChartPainter oldDelegate) {
    return oldDelegate.rows != rows ||
        oldDelegate.incomeColor != incomeColor ||
        oldDelegate.expenseColor != expenseColor;
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.rows,
    required this.lineColor,
    required this.pointFill,
  });

  final List<_TableRowData> rows;
  final Color lineColor;
  final Color pointFill;

  @override
  void paint(Canvas canvas, Size size) {
    if (rows.isEmpty) return;

    final values = rows.map((row) => row.balance.toDouble()).toList();
    final rawMax = values.reduce((a, b) => a > b ? a : b);
    final rawMin = values.reduce((a, b) => a < b ? a : b);
    final maxValue = rawMax < 1 ? 1.0 : rawMax;
    final minValue = rawMin > 0 ? 0.0 : rawMin;
    final range = (maxValue - minValue).abs() < 1 ? 1.0 : (maxValue - minValue);

    final chartPadding = const EdgeInsets.fromLTRB(8, 8, 8, 20);
    final chartWidth = size.width - chartPadding.horizontal;
    final chartHeight = size.height - chartPadding.vertical;

    final pointGap = rows.length == 1 ? 0 : chartWidth / (rows.length - 1);

    final axisPaint = Paint()
      ..color = const Color(0x1A000000)
      ..strokeWidth = 1;
    final baseY = chartPadding.top + chartHeight;

    canvas.drawLine(
      Offset(chartPadding.left, baseY),
      Offset(chartPadding.left + chartWidth, baseY),
      axisPaint,
    );

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (var i = 0; i < rows.length; i++) {
      final value = rows[i].balance.toDouble();
      final x = chartPadding.left + pointGap * i;
      final normalized = (value - minValue) / range;
      final y = chartPadding.top + chartHeight - (normalized * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    final pointPaint = Paint()..color = pointFill;
    for (var i = 0; i < rows.length; i++) {
      final value = rows[i].balance.toDouble();
      final x = chartPadding.left + pointGap * i;
      final normalized = (value - minValue) / range;
      final y = chartPadding.top + chartHeight - (normalized * chartHeight);

      canvas.drawCircle(Offset(x, y), 4.2, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.rows != rows ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.pointFill != pointFill;
  }
}

class _StatTable extends StatelessWidget {
  const _StatTable({required this.rows});

  final List<_TableRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: const Color(0x0F000000),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "周期",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B5A60),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "收礼",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B5A60),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "随礼",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B5A60),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "结余",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B5A60),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...rows.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final row = entry.value;
                final isLast = index == rows.length - 1;

                return Container(
                  margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? Colors.transparent
                        : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.period,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "¥${row.income}",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF198754),
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "¥${row.expense}",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFFB02A37),
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: row.balance >= 0
                                ? const Color(0xFF198754).withValues(alpha: 0.1)
                                : const Color(0xFFB02A37).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "¥${row.balance}",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: row.balance >= 0
                                      ? const Color(0xFF198754)
                                      : const Color(0xFFB02A37),
                                  fontWeight: FontWeight.w700,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
  final _relationshipController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = "收礼";
  String _relationship = "朋友";
  DateTime _date = DateTime(2026, 3, 15);

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
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop();
                }
              },
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
                          hintText: "例如：客户 / 伙伴",
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
                        hintText: "例如：婚礼 / 满月",
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
                        hintText: "例如：500",
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
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.of(context).pop();
                      }
                    },
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
