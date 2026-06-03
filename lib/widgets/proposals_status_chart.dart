import 'package:flutter/material.dart';

class ProposalsStatusChart extends StatelessWidget {
  const ProposalsStatusChart({
    super.key,
    required this.statusCounts,
  });

  final Map<String, int> statusCounts;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA000);
      case 'in_progress':
        return const Color(0xFF1565C0);
      case 'successful':
        return const Color(0xFF2E7D32);
      case 'no_response':
        return const Color(0xFF757575);
      case 'no_deal':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF757575);
    }
  }

  String _getDisplayLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'successful':
        return 'Successful';
      case 'no_response':
        return 'No Response';
      case 'no_deal':
        return 'No Deal';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = statusCounts.values.fold<int>(0, (a, b) => a + b);

    if (totalCount == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proposal Pipeline',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'No proposals recorded yet',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final statusOrder = ['pending', 'in_progress', 'successful', 'no_response', 'no_deal'];
    final filteredStatuses = statusOrder.where((s) => statusCounts.containsKey(s)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Proposal Pipeline',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: CustomPaint(
            painter: _BarChartPainter(
              statusCounts: statusCounts,
              statusOrder: statusOrder,
              getColor: _getStatusColor,
              totalCount: totalCount,
            ),
            size: const Size(double.infinity, 160),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: filteredStatuses.map((status) {
            final count = statusCounts[status] ?? 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${_getDisplayLabel(status)}: $count',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.statusCounts,
    required this.statusOrder,
    required this.getColor,
    required this.totalCount,
  });

  final Map<String, int> statusCounts;
  final List<String> statusOrder;
  final Color Function(String) getColor;
  final int totalCount;

  @override
  void paint(Canvas canvas, Size size) {
    final spacing = 12.0;
    final startX = 0.0;
    final endX = size.width;
    final barWidth = endX - startX;

    final visibleStatuses =
        statusOrder.where((s) => statusCounts.containsKey(s)).toList();
    final totalBars = visibleStatuses.length;
    final totalSpacing = spacing * (totalBars - 1);
    final availableHeight = size.height - totalSpacing;
    final singleBarHeight = availableHeight / totalBars;

    double currentY = 0;

    for (final status in visibleStatuses) {
      final count = statusCounts[status] ?? 0;
      final percentage = count / totalCount;
      final fillWidth = barWidth * percentage;

      // Draw background bar
      final bgPaint = Paint()
        ..color = const Color(0xFFE7E5E4)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX, currentY, barWidth, singleBarHeight),
          const Radius.circular(8),
        ),
        bgPaint,
      );

      // Draw filled bar
      final fillPaint = Paint()
        ..color = getColor(status)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX, currentY, fillWidth, singleBarHeight),
          const Radius.circular(8),
        ),
        fillPaint,
      );

      currentY += singleBarHeight + spacing;
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) {
    return oldDelegate.statusCounts != statusCounts;
  }
}
