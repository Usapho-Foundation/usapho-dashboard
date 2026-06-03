import 'package:flutter/material.dart';

class RevenueOverviewCard extends StatelessWidget {
  const RevenueOverviewCard({super.key, required this.categoryData});

  final List<Map<String, dynamic>> categoryData;

  String _formatCurrency(double value) {
    // Simple regex-based formatter consistent with repo conventions
    final parts = value.toStringAsFixed(2).split('.');
    final integer = parts[0];
    final decimals = parts[1];
    final regex = RegExp(r"(\d+)(\d{3})");
    var formatted = integer;
    while (regex.hasMatch(formatted)) {
      formatted = formatted.replaceAllMapped(regex, (m) => '${m[1]},${m[2]}');
    }
    return 'R $formatted.$decimals';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Revenue by Funding Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Live breakdown of received funding by source category',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: categoryData.map((cat) {
                final total = (cat['totalRevenue'] as double?) ?? 0.0;
                final unrestricted = (cat['unrestricted'] as double?) ?? 0.0;
                final restricted = (cat['restricted'] as double?) ?? 0.0;
                final unrestrictedPct = (cat['unrestrictedPct'] as double?) ?? 0.0;
                final restrictedPct = (cat['restrictedPct'] as double?) ?? 0.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 12),
                    Text(
                      cat['label'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (total == 0)
                      Text(
                        'No revenue recorded yet',
                        style: const TextStyle(color: Color(0xFF6B7280)),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Revenue: ${_formatCurrency(total)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Unrestricted: ${_formatCurrency(unrestricted)} (${unrestrictedPct.toStringAsFixed(0)}%)',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (unrestrictedPct / 100).clamp(0.0, 1.0),
                              minHeight: 6,
                              color: const Color(0xFF1565C0),
                              backgroundColor: const Color(0xFFE5E7EB),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Restricted: ${_formatCurrency(restricted)} (${restrictedPct.toStringAsFixed(0)}%)',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (restrictedPct / 100).clamp(0.0, 1.0),
                              minHeight: 6,
                              color: const Color(0xFF2E7D32),
                              backgroundColor: const Color(0xFFE5E7EB),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
