import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: child),
          ],
        ),
      ),
    );
  }
}

// ── Funding Funnel ────────────────────────────────────────────────────────────

class FunnelChart extends StatelessWidget {
  const FunnelChart({super.key, required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    if (values.every((v) => v == 0)) {
      return const Center(
        child: Text(
          'Add funding opportunities to see the funnel.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
        ),
      );
    }

    final maxValue = values.reduce(max).clamp(1.0, double.infinity);
    const labels = ['Pipeline', 'Approved', 'Received'];
    const colors = [
      Color(0xFF93C5FD),
      Color(0xFF4ADE80),
      Color(0xFF1F6A5A),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(values.length, (i) {
        final ratio = (values[i] / maxValue).clamp(0.0, 1.0);
        return Row(
          children: [
            SizedBox(
              width: 68,
              child: Text(
                labels[i],
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final barWidth = constraints.maxWidth * ratio;
                  return Stack(
                    children: [
                      Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      if (barWidth > 0)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            width: barWidth,
                            height: 36,
                            color: colors[i],
                          ),
                        ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _shortNum(values[i]),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ratio > 0.25
                                    ? Colors.white
                                    : const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  String _shortNum(double value) {
    if (value >= 1000000) return 'R${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return 'R${(value / 1000).toStringAsFixed(0)}k';
    return 'R${value.toStringAsFixed(0)}';
  }
}

// ── Cash Balance Trend Line Chart ─────────────────────────────────────────────

class LineTrendChart extends StatelessWidget {
  const LineTrendChart({super.key, required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return Center(
        child: Text(
          values.isEmpty
              ? 'Add financial records to see the trend.'
              : 'Add more records to see a trend.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
        ),
      );
    }

    final maxV = values.reduce(max);
    final minV = values.reduce(min);
    final range = (maxV - minV).clamp(1.0, double.infinity);
    final pad = range * 0.15;

    final spots = values.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return LineChart(
      LineChartData(
        minY: minV - pad,
        maxY: maxV + pad,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (range + 2 * pad) / 4,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFFF0EFEC), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF1F6A5A),
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                radius: 4,
                color: const Color(0xFF1F6A5A),
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1F6A5A).withValues(alpha: 0.18),
                  const Color(0xFF1F6A5A).withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Monthly Cash Flow Bar Chart ───────────────────────────────────────────────

class CashFlowBarChart extends StatelessWidget {
  const CashFlowBarChart({
    super.key,
    required this.cashIn,
    required this.cashOut,
    required this.labels,
  });

  final List<double> cashIn;
  final List<double> cashOut;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    if (cashIn.isEmpty) {
      return const Center(
        child: Text(
          'Add financial records to see monthly cash flow.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
        ),
      );
    }

    final allValues = [...cashIn, ...cashOut];
    final maxV = allValues.reduce(max).clamp(1.0, double.infinity);

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: maxV * 1.2,
              barGroups: List.generate(cashIn.length, (i) => BarChartGroupData(
                x: i,
                barsSpace: 3,
                barRods: [
                  BarChartRodData(
                    toY: cashIn[i],
                    color: const Color(0xFF4ADE80),
                    width: 10,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                  BarChartRodData(
                    toY: cashOut[i],
                    color: const Color(0xFFF87171),
                    width: 10,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              )),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxV / 4,
                getDrawingHorizontalLine: (_) =>
                    const FlLine(color: Color(0xFFF0EFEC), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          labels[i],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(enabled: false),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: const Color(0xFF4ADE80), label: 'Cash In'),
            const SizedBox(width: 20),
            _LegendDot(color: const Color(0xFFF87171), label: 'Cash Out'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}
