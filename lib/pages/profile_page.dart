import "package:flutter/material.dart";
import "../widgets/shell_scaffold.dart";

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellScaffold(
      currentIndex: 1,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: const Text("我的"),
              actions: [
                Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      icon: const Icon(Icons.settings),
                      tooltip: "设置",
                    );
                  },
                ),
              ],
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
                      "张小六?",
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
                      text: "当前位置：上海?",
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
                  label: "收入",
                  color: Color(0xFF198754),
                ),
                _LegendItem(
                  label: "支出",
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
                  label: "结余",
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
                          "￥${row.income}",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF198754),
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "￥${row.expense}",
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
                            "￥${row.balance}",
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
