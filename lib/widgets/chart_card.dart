import 'dart:math';

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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 18),
            SizedBox(height: 220, child: child),
          ],
        ),
      ),
    );
  }
}

class FunnelChart extends StatelessWidget {
  const FunnelChart({super.key, required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty
        ? 1.0
        : values.reduce(max).clamp(1, double.infinity);
    final labels = const ['Pipeline', 'Approved', 'Received'];
    final colors = const [
      Color(0xFFBFD7EA),
      Color(0xFF7FB069),
      Color(0xFF1F6A5A),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(values.length, (index) {
        final ratio = values[index] / maxValue;
        return Row(
          children: [
            SizedBox(width: 76, child: Text(labels[index])),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: ratio.clamp(0, 1),
                  minHeight: 24,
                  backgroundColor: const Color(0xFFE7E5E4),
                  color: colors[index],
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 72,
              child: Text(
                'R${values[index].toStringAsFixed(0)}',
                textAlign: TextAlign.right,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class LineTrendChart extends StatelessWidget {
  const LineTrendChart({super.key, required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const Center(child: Text('Add data to see a trend line.'));
    }

    return CustomPaint(painter: _LineChartPainter(values), child: Container());
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = const Color(0xFFD6D3D1)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = const Color(0xFF1F6A5A)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x331F6A5A), Color(0x051F6A5A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      axisPaint,
    );

    final maxValue = values.reduce(max).clamp(1, double.infinity);
    final minValue = values.reduce(min);
    final span = (maxValue - minValue).clamp(1, double.infinity);
    final stepX = values.length == 1
        ? size.width
        : size.width / (values.length - 1);

    final linePath = Path();
    final fillPath = Path();

    for (int i = 0; i < values.length; i++) {
      final dx = stepX * i;
      final normalized = (values[i] - minValue) / span;
      final dy = size.height - (normalized * (size.height - 24)) - 12;
      final point = Offset(dx, dy);
      if (i == 0) {
        linePath.moveTo(point.dx, point.dy);
        fillPath.moveTo(point.dx, size.height);
        fillPath.lineTo(point.dx, point.dy);
      } else {
        linePath.lineTo(point.dx, point.dy);
        fillPath.lineTo(point.dx, point.dy);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
