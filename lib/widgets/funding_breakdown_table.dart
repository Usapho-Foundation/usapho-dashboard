import 'package:flutter/material.dart';

import '../models/funding_opportunity.dart';
import 'funding_status_badge.dart';

class FundingBreakdownTable extends StatelessWidget {
  const FundingBreakdownTable({
    super.key,
    required this.funding,
  });

  final List<FundingOpportunity> funding;

  String _formatCurrency(double value) {
    return 'R${value.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildRestrictedFundingSection(),
          const SizedBox(height: 16),
          _buildUnrestrictedFundingSection(),
          const SizedBox(height: 16),
          _buildProposalSubmissionsSection(),
          const SizedBox(height: 16),
          _buildOtherIncomeSection(),
          const SizedBox(height: 16),
          _buildForecastSection(),
        ],
      ),
    );
  }

  Widget _buildRestrictedFundingSection() {
    final restricted = funding.where((item) => item.type == 'restricted').toList();
    final totalAnnually = restricted.fold<double>(0, (sum, item) => sum + item.annually);
    final totalReceived = restricted.fold<double>(0, (sum, item) => sum + item.amountReceivedToDate);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'Restricted Funding',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          if (restricted.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'No records yet',
                style: TextStyle(fontSize: 12, color: const Color(0xFF6B7280)),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                dataRowMinHeight: 40,
                columns: const [
                  DataColumn(label: Text('Funder')),
                  DataColumn(label: Text('Annually (R)')),
                  DataColumn(label: Text('Quarterly (R)')),
                  DataColumn(label: Text('Funding Period')),
                  DataColumn(label: Text('Cohort Target')),
                  DataColumn(label: Text('Cohort Actual')),
                  DataColumn(label: Text('Comments')),
                ],
                rows: [
                  ...restricted.map((item) => DataRow(
                    cells: [
                      DataCell(Text(item.funderName)),
                      DataCell(Text(_formatCurrency(item.annually))),
                      DataCell(Text(_formatCurrency(item.quarterly))),
                      DataCell(Text(item.fundingPeriod)),
                      DataCell(Text(item.cohortTarget.toString())),
                      DataCell(Text(item.cohortActual.toString())),
                      DataCell(Text(item.comments)),
                    ],
                  )),
                  DataRow(
                    color: WidgetStateProperty.resolveWith((states) => const Color(0xFFFAFAFA)),
                    cells: [
                      const DataCell(Text(
                        'SUBTOTAL',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )),

                      DataCell(Text(
                        _formatCurrency(totalAnnually),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      DataCell(Text(
                        'Received: ${_formatCurrency(totalReceived)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUnrestrictedFundingSection() {
    final unrestricted = funding.where((item) => item.type == 'unrestricted').toList();
    final totalApplied = unrestricted.fold<double>(0, (sum, item) => sum + item.amountAppliedFor);
    final totalReceived = unrestricted.fold<double>(0, (sum, item) => sum + item.amountReceivedToDate);
    final totalTarget = unrestricted.fold<double>(0, (sum, item) => sum + item.target);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'Unrestricted Funding',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          if (unrestricted.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'No records yet',
                style: TextStyle(fontSize: 12, color: const Color(0xFF6B7280)),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                dataRowMinHeight: 40,
                columns: const [
                  DataColumn(label: Text('Donor')),
                  DataColumn(label: Text('Monthly (R)')),
                  DataColumn(label: Text('Amount Applied (R)')),
                  DataColumn(label: Text('Received to Date (R)')),
                  DataColumn(label: Text('Target (R)')),
                  DataColumn(label: Text('Comments')),
                ],
                rows: [
                  ...unrestricted.map((item) => DataRow(
                    cells: [
                      DataCell(Text(item.funderName)),
                      DataCell(Text(_formatCurrency(item.monthly))),
                      DataCell(Text(_formatCurrency(item.amountAppliedFor))),
                      DataCell(Text(_formatCurrency(item.amountReceivedToDate))),
                      DataCell(Text(_formatCurrency(item.target))),
                      DataCell(Text(item.comments)),
                    ],
                  )),
                  DataRow(
                    color: WidgetStateProperty.resolveWith((states) => const Color(0xFFFAFAFA)),
                    cells: [
                      const DataCell(Text(
                        'SUBTOTAL',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )),

                      const DataCell(Text('')),
                      DataCell(Text(
                        _formatCurrency(totalApplied),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(
                        _formatCurrency(totalReceived),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(
                        _formatCurrency(totalTarget),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )),
                      const DataCell(Text('')),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProposalSubmissionsSection() {
    final proposals = funding.where((item) => item.type == 'proposal').toList();
    final totalApplied = proposals.fold<double>(0, (sum, item) => sum + item.amountAppliedFor);
    final totalReceived = proposals.fold<double>(0, (sum, item) => sum + item.amountReceivedToDate);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'Proposal Submissions',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          if (proposals.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'No records yet',
                style: TextStyle(fontSize: 12, color: const Color(0xFF6B7280)),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                dataRowMinHeight: 40,
                columns: const [
                  DataColumn(label: Text('Organisation')),
                  DataColumn(label: Text('Date Submitted')),
                  DataColumn(label: Text('Stakeholder')),
                  DataColumn(label: Text('Amount Applied (R)')),
                  DataColumn(label: Text('Received (R)')),
                  DataColumn(label: Text('Responsible')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Update')),
                ],
                rows: [
                  ...proposals.map((item) => DataRow(
                    cells: [
                      DataCell(Text(item.funderName)),
                      DataCell(Text(_formatDate(item.dateSubmitted))),
                      DataCell(Text(item.stakeholderContact)),
                      DataCell(Text(_formatCurrency(item.amountAppliedFor))),
                      DataCell(Text(_formatCurrency(item.amountReceivedToDate))),
                      DataCell(Text(item.personResponsible)),
                      DataCell(FundingStatusBadge(status: item.status)),
                      DataCell(Text(item.update, maxLines: 2, overflow: TextOverflow.ellipsis)),
                    ],
                  )),
                  DataRow(
                    color: WidgetStateProperty.resolveWith((states) => const Color(0xFFFAFAFA)),
                    cells: [
                      const DataCell(Text(
                        'SUBTOTAL',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )),

                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      DataCell(Text(
                        _formatCurrency(totalApplied),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(
                        _formatCurrency(totalReceived),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOtherIncomeSection() {
    final incomeActivities = funding.where((item) => item.type == 'income_activity').toList();
    final totalTarget = incomeActivities.fold<double>(0, (sum, item) => sum + item.target);
    final totalActual = incomeActivities.fold<double>(0, (sum, item) => sum + item.actual);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'Other Income Activities',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          if (incomeActivities.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'No records yet',
                style: TextStyle(fontSize: 12, color: const Color(0xFF6B7280)),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                dataRowMinHeight: 40,
                columns: const [
                  DataColumn(label: Text('Activity')),
                  DataColumn(label: Text('Target (R)')),
                  DataColumn(label: Text('Actual (R)')),
                ],
                rows: [
                  ...incomeActivities.map((item) => DataRow(
                    cells: [
                      DataCell(Text(item.funderName)),
                      DataCell(Text(_formatCurrency(item.target))),
                      DataCell(Text(_formatCurrency(item.actual))),
                    ],
                  )),
                  DataRow(
                    color: WidgetStateProperty.resolveWith((states) => const Color(0xFFFAFAFA)),
                    cells: [
                      const DataCell(Text(
                        'SUBTOTAL',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )),

                      DataCell(Text(
                        _formatCurrency(totalTarget),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(
                        _formatCurrency(totalActual),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForecastSection() {
    final forecasts = funding.where((item) => item.type == 'forecast').toList();
    final totalForecasted = forecasts.fold<double>(0, (sum, item) => sum + item.forecastedIncome);
    final totalActual = forecasts.fold<double>(0, (sum, item) => sum + item.actual);
    final totalDifference = totalForecasted - totalActual;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'Income Forecast',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          if (forecasts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'No records yet',
                style: TextStyle(fontSize: 12, color: const Color(0xFF6B7280)),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                dataRowMinHeight: 40,
                columns: const [
                  DataColumn(label: Text('Source')),
                  DataColumn(label: Text('Forecasted Income (R)')),
                  DataColumn(label: Text('Actual to Date (R)')),
                  DataColumn(label: Text('Difference (R)')),
                ],
                rows: [
                  ...forecasts.map((item) {
                    final difference = item.forecastedIncome - item.actual;
                    return DataRow(
                      cells: [
                        DataCell(Text(item.funderName)),
                        DataCell(Text(_formatCurrency(item.forecastedIncome))),
                        DataCell(Text(_formatCurrency(item.actual))),
                        DataCell(
                          Text(
                            _formatCurrency(difference),
                            style: TextStyle(
                              color: difference < 0 ? const Color(0xFFC62828) : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  DataRow(
                    color: WidgetStateProperty.resolveWith((states) => const Color(0xFFFAFAFA)),
                    cells: [
                      const DataCell(Text(
                        'SUBTOTAL',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )),

                      DataCell(Text(
                        _formatCurrency(totalForecasted),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(
                        _formatCurrency(totalActual),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )),
                      DataCell(
                        Text(
                          _formatCurrency(totalDifference),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: totalDifference < 0 ? const Color(0xFFC62828) : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
