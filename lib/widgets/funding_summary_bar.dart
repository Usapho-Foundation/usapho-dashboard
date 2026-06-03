import 'package:flutter/material.dart';

import '../logic/dashboard_calculations.dart';
import '../models/funding_opportunity.dart';

class FundingSummaryBar extends StatelessWidget {
  const FundingSummaryBar({
    super.key,
    required this.funding,
  });

  final List<FundingOpportunity> funding;

  String _formatCurrency(double value) {
    return 'R${value.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final summary = DashboardCalculations.incomeForecastSummary(funding);
    final forecastedTotal = summary['forecastedTotal'] as double? ?? 0.0;
    final percentageAchieved = summary['percentageAchieved'] as double? ?? 0.0;
    final receivedAllFunding = funding.fold<double>(
      0.0,
      (sum, item) => sum + item.amountReceivedToDate,
    );
    final progressValue = (percentageAchieved.clamp(0.0, 100.0) / 100.0);
    final progressColor = progressValue >= 0.5
        ? const Color(0xFF2E7D32)
        : progressValue >= 0.25
            ? const Color(0xFFFFA000)
            : const Color(0xFFC62828);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Funding Received',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatCurrency(receivedAllFunding),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'of ${_formatCurrency(forecastedTotal)} forecasted (${percentageAchieved.toStringAsFixed(0)}%)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progressValue,
                    strokeWidth: 5,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                  Text(
                    '${percentageAchieved.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
