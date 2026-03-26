import 'package:flutter/material.dart';

import '../logic/dashboard_calculations.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({super.key, required this.metric, required this.onTap});

  final DashboardMetric metric;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (metric.health) {
      MetricHealth.good => const Color(0xFF2E7D32),
      MetricHealth.warning => const Color(0xFFED9B00),
      MetricHealth.critical => const Color(0xFFC62828),
      MetricHealth.neutral => const Color(0xFF6B7280),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7E5E4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    metric.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              metric.value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              metric.subtitle,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
