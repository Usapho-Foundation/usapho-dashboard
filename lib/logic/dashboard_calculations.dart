import 'dart:math';

import '../models/campaign_record.dart';
import '../models/dashboard_filter.dart';
import '../models/financial_record.dart';
import '../models/funding_opportunity.dart';
import '../models/partnership.dart';
import '../models/program_record.dart';

enum MetricHealth { good, warning, critical, neutral }

class MetricDetail {
  const MetricDetail({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final String trailing;
}

class DashboardMetric {
  const DashboardMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.health,
    required this.details,
  });

  final String title;
  final String value;
  final String subtitle;
  final MetricHealth health;
  final List<MetricDetail> details;
}

class DashboardSection {
  const DashboardSection({
    required this.title,
    required this.description,
    required this.metrics,
  });

  final String title;
  final String description;
  final List<DashboardMetric> metrics;
}

class AlertItem {
  const AlertItem({
    required this.title,
    required this.message,
    required this.health,
  });

  final String title;
  final String message;
  final MetricHealth health;
}

class DashboardOverview {
  const DashboardOverview({
    required this.sections,
    required this.funnelValues,
    required this.cashTrend,
    required this.fundingTrend,
    required this.alerts,
  });

  final List<DashboardSection> sections;
  final List<double> funnelValues;
  final List<double> cashTrend;
  final List<double> fundingTrend;
  final List<AlertItem> alerts;
}

class DateWindow {
  const DateWindow({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

class DashboardCalculations {
  static DateWindow? rangeForPreset(DatePreset preset, DateTime now) {
    switch (preset) {
      case DatePreset.allTime:
        return null;
      case DatePreset.currentQuarter:
        final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        final start = DateTime(now.year, quarterStartMonth, 1);
        final end = DateTime(now.year, quarterStartMonth + 3, 0, 23, 59, 59);
        return DateWindow(start: start, end: end);
      case DatePreset.last6Months:
        return DateWindow(
          start: DateTime(now.year, now.month - 5, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
    }
  }

  static DashboardOverview buildOverview({
    required List<FundingOpportunity> funding,
    required List<Partnership> partnerships,
    required List<ProgramRecord> programs,
    required List<CampaignRecord> campaigns,
    required List<FinancialRecord> financials,
  }) {
    return DashboardOverview(
      sections: [
        _fundingSection(funding),
        _partnershipSection(partnerships),
        _programSection(programs),
        _marketingSection(campaigns),
        _financialSection(financials, funding),
      ],
      funnelValues: _funnel(funding),
      cashTrend: _cashTrend(financials),
      fundingTrend: _fundingTrend(funding),
      alerts: _alerts(funding, partnerships),
    );
  }

  static DashboardSection _fundingSection(List<FundingOpportunity> funding) {
    final totalReceived = funding.fold<double>(
      0,
      (sum, item) => sum + item.amountReceived,
    );
    final pipelineValue = funding
        .where((item) => item.status != 'received')
        .fold<double>(0, (sum, item) => sum + item.amountApplied);
    final applied = funding.fold<double>(
      0,
      (sum, item) => sum + item.amountApplied,
    );
    final approved = funding.fold<double>(
      0,
      (sum, item) => sum + item.amountApproved,
    );
    final conversionRate = applied == 0 ? 0.0 : (approved / applied) * 100;
    final activeOpportunities = funding
        .where((item) => item.status != 'received' && item.status != 'declined')
        .length;

    return DashboardSection(
      title: 'Corporate & Foundation Funding',
      description: 'Track the health of active opportunities and conversion.',
      metrics: [
        DashboardMetric(
          title: 'Total Funding Secured',
          value: _currency(totalReceived),
          subtitle: 'Funds received from confirmed opportunities',
          health: _moneyHealth(
            totalReceived,
            warningFloor: 250000,
            goodFloor: 750000,
          ),
          details: funding
              .where((item) => item.amountReceived > 0)
              .map(
                (item) => MetricDetail(
                  title: item.opportunityName,
                  subtitle: item.entityName,
                  trailing: _currency(item.amountReceived),
                ),
              )
              .toList(),
        ),
        DashboardMetric(
          title: 'Pipeline Value',
          value: _currency(pipelineValue),
          subtitle: 'Potential value still in play',
          health: _moneyHealth(
            pipelineValue,
            warningFloor: 200000,
            goodFloor: 600000,
          ),
          details: funding
              .where((item) => item.status != 'received')
              .map(
                (item) => MetricDetail(
                  title: item.opportunityName,
                  subtitle: '${item.status} - ${item.owner}',
                  trailing: _currency(item.amountApplied),
                ),
              )
              .toList(),
        ),
        DashboardMetric(
          title: 'Conversion Rate',
          value: '${conversionRate.toStringAsFixed(1)}%',
          subtitle: 'Approved value over applied value',
          health: _percentageHealth(
            conversionRate,
            warningFloor: 30,
            goodFloor: 55,
          ),
          details: funding
              .map(
                (item) => MetricDetail(
                  title: item.opportunityName,
                  subtitle: item.entityName,
                  trailing:
                      '${item.probability.toStringAsFixed(0)}% probability',
                ),
              )
              .toList(),
        ),
        DashboardMetric(
          title: 'Active Opportunities',
          value: '$activeOpportunities',
          subtitle: 'Pipeline and submitted opportunities',
          health: activeOpportunities >= 8
              ? MetricHealth.good
              : activeOpportunities >= 4
              ? MetricHealth.warning
              : MetricHealth.critical,
          details: funding
              .where(
                (item) =>
                    item.status != 'received' && item.status != 'declined',
              )
              .map(
                (item) => MetricDetail(
                  title: item.opportunityName,
                  subtitle: item.entityName,
                  trailing: item.status,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  static DashboardSection _partnershipSection(List<Partnership> partnerships) {
    final activePartners = partnerships
        .where((item) => item.status == 'active')
        .length;
    final quarterStart = rangeForPreset(
      DatePreset.currentQuarter,
      DateTime.now(),
    )!.start;
    final newPartners = partnerships
        .where(
          (item) =>
              item.createdAt != null && item.createdAt!.isAfter(quarterStart),
        )
        .length;
    final engagementScore = partnerships.isEmpty
        ? 0.0
        : partnerships
                  .map((item) => _engagementScore(item.engagementLevel))
                  .reduce((a, b) => a + b) /
              partnerships.length;
    final jointInitiatives = partnerships.fold<int>(
      0,
      (sum, item) => sum + item.activityCount,
    );

    return DashboardSection(
      title: 'Partnerships',
      description:
          'See how partner relationships are growing and staying active.',
      metrics: [
        DashboardMetric(
          title: 'Active Partners',
          value: '$activePartners',
          subtitle: 'Partners currently marked active',
          health: activePartners >= 8
              ? MetricHealth.good
              : activePartners >= 4
              ? MetricHealth.warning
              : MetricHealth.critical,
          details: partnerships
              .where((item) => item.status == 'active')
              .map(
                (item) => MetricDetail(
                  title: item.partnerName,
                  subtitle: '${item.type} - ${item.owner}',
                  trailing: item.engagementLevel,
                ),
              )
              .toList(),
        ),
        DashboardMetric(
          title: 'New Partners',
          value: '$newPartners',
          subtitle: 'Added this quarter',
          health: newPartners >= 3
              ? MetricHealth.good
              : newPartners >= 1
              ? MetricHealth.warning
              : MetricHealth.critical,
          details: partnerships
              .where(
                (item) =>
                    item.createdAt != null &&
                    item.createdAt!.isAfter(quarterStart),
              )
              .map(
                (item) => MetricDetail(
                  title: item.partnerName,
                  subtitle: item.type,
                  trailing: item.status,
                ),
              )
              .toList(),
        ),
        DashboardMetric(
          title: 'Engagement Level',
          value: engagementScore.toStringAsFixed(1),
          subtitle: 'Average partner engagement score out of 3',
          health: engagementScore >= 2.5
              ? MetricHealth.good
              : engagementScore >= 1.8
              ? MetricHealth.warning
              : MetricHealth.critical,
          details: partnerships
              .map(
                (item) => MetricDetail(
                  title: item.partnerName,
                  subtitle: item.owner,
                  trailing: item.engagementLevel,
                ),
              )
              .toList(),
        ),
        DashboardMetric(
          title: 'Joint Initiatives',
          value: '$jointInitiatives',
          subtitle: 'Activities logged with partners',
          health: jointInitiatives >= 10
              ? MetricHealth.good
              : jointInitiatives >= 5
              ? MetricHealth.warning
              : MetricHealth.critical,
          details: partnerships
              .map(
                (item) => MetricDetail(
                  title: item.partnerName,
                  subtitle: item.status,
                  trailing: '${item.activityCount} activities',
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  static DashboardSection _programSection(List<ProgramRecord> programs) {
    final beneficiaries = programs.fold<int>(
      0,
      (sum, item) => sum + item.participants,
    );
    final delivered = programs.where((item) => item.status != 'planned').length;
    final completionRate = programs.isEmpty
        ? 0.0
        : programs.map((item) => item.completionRate).reduce((a, b) => a + b) /
              programs.length;
    final impactScore = programs.isEmpty
        ? 0.0
        : programs.map((item) => item.impactScore).reduce((a, b) => a + b) /
              programs.length;

    return DashboardSection(
      title: 'Program Delivery',
      description: 'Measure how effectively programs are reaching people.',
      metrics: [
        DashboardMetric(
          title: 'Beneficiaries',
          value: '$beneficiaries',
          subtitle: 'People reached across active programs',
          health: beneficiaries >= 500
              ? MetricHealth.good
              : beneficiaries >= 250
              ? MetricHealth.warning
              : MetricHealth.critical,
          details: programs
              .map(
                (item) => MetricDetail(
                  title: item.programName,
                  subtitle: item.programLead,
                  trailing: '${item.participants} participants',
                ),
              )
              .toList(),
        ),
        DashboardMetric(
          title: 'Programs Delivered',
          value: '$delivered',
          subtitle: 'Programs underway or completed',
          health: delivered >= 4
              ? MetricHealth.good
              : delivered >= 2
              ? MetricHealth.warning
              : MetricHealth.critical,
          details: programs
              .map(
                (item) => MetricDetail(
                  title: item.programName,
                  subtitle: item.status,
                  trailing: item.fundingSource,
                ),
              )
              .toList(),
        ),
        DashboardMetric(
          title: 'Completion Rate',
          value: '${completionRate.toStringAsFixed(1)}%',
          subtitle: 'Average completion across programs',
          health: _percentageHealth(
            completionRate,
            warningFloor: 60,
            goodFloor: 85,
          ),
          details: programs
              .map(
                (item) => MetricDetail(
                  title: item.programName,
                  subtitle: item.programLead,
                  trailing: '${item.completionRate.toStringAsFixed(0)}%',
                ),
              )
              .toList(),
        ),
        DashboardMetric(
          title: 'Impact Score',
          value: impactScore.toStringAsFixed(1),
          subtitle: 'Average self-reported impact score',
          health: impactScore >= 4
              ? MetricHealth.good
              : impactScore >= 3
              ? MetricHealth.warning
              : MetricHealth.critical,
          details: programs
              .map(
                (item) => MetricDetail(
                  title: item.programName,
                  subtitle: item.status,
                  trailing: item.impactScore.toStringAsFixed(1),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  static DashboardSection _marketingSection(List<CampaignRecord> campaigns) {
    final reach = campaigns.fold<int>(0, (sum, item) => sum + item.reach);
    final engagement = campaigns.fold<int>(
      0,
      (sum, item) => sum + item.engagement,
    );
    final leads = campaigns.fold<int>(
      0,
      (sum, item) => sum + item.leadsGenerated,
    );
    final engagementRate = reach == 0 ? 0.0 : (engagement / reach) * 100;

    return DashboardSection(
      title: 'Marketing & Visibility',
      description:
          'Keep campaign performance visible without overwhelming leaders.',
      metrics: [
        DashboardMetric(
          title: 'Reach',
          value: '$reach',
          subtitle: 'Total audience reached',
          health: reach >= 20000
              ? MetricHealth.good
              : reach >= 10000
              ? MetricHealth.warning
              : MetricHealth.critical,
          details: campaigns
              .map(
                (item) => MetricDetail(
                  title: item.campaignName,
                  subtitle: item.channel,
                  trailing: '${item.reach} reach',
                ),
              )
              .toList(),
        ),
        DashboardMetric(
          title: 'Engagement Rate',
          value: '${engagementRate.toStringAsFixed(1)}%',
          subtitle: 'Engagements over total reach',
          health: _percentageHealth(
            engagementRate,
            warningFloor: 2,
            goodFloor: 5,
          ),
          details: campaigns
              .map(
                (item) => MetricDetail(
                  title: item.campaignName,
                  subtitle: item.channel,
                  trailing: '${item.engagement} engagements',
                ),
              )
              .toList(),
        ),
        DashboardMetric(
          title: 'Campaigns Run',
          value: '${campaigns.length}',
          subtitle: 'Campaigns in the selected period',
          health: campaigns.length >= 4
              ? MetricHealth.good
              : campaigns.length >= 2
              ? MetricHealth.warning
              : MetricHealth.critical,
          details: campaigns
              .map(
                (item) => MetricDetail(
                  title: item.campaignName,
                  subtitle: item.owner,
                  trailing: item.channel,
                ),
              )
              .toList(),
        ),
        DashboardMetric(
          title: 'Leads Generated',
          value: '$leads',
          subtitle: 'Potential supporters or partners captured',
          health: leads >= 100
              ? MetricHealth.good
              : leads >= 40
              ? MetricHealth.warning
              : MetricHealth.critical,
          details: campaigns
              .map(
                (item) => MetricDetail(
                  title: item.campaignName,
                  subtitle: item.channel,
                  trailing: '${item.leadsGenerated} leads',
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  static DashboardSection _financialSection(
    List<FinancialRecord> financials,
    List<FundingOpportunity> funding,
  ) {
    final sorted = [...financials]
      ..sort(
        (a, b) =>
            (a.month ?? DateTime(1900)).compareTo(b.month ?? DateTime(1900)),
      );
    final latest = sorted.isEmpty ? null : sorted.last;
    final burnRate = financials.isEmpty
        ? 0.0
        : financials.map((item) => item.cashOut).reduce((a, b) => a + b) /
              financials.length;
    final runway = burnRate == 0 || latest == null
        ? 0.0
        : latest.balance / burnRate;
    final diversity = funding
        .where((item) => item.amountReceived > 0)
        .map((item) => item.entityName)
        .toSet()
        .length;

    return DashboardSection(
      title: 'Financial Sustainability',
      description: 'Understand runway and stability at a glance.',
      metrics: [
        DashboardMetric(
          title: 'Cash Balance',
          value: _currency(latest?.balance ?? 0),
          subtitle: 'Most recent closing balance',
          health: _moneyHealth(
            latest?.balance ?? 0,
            warningFloor: 150000,
            goodFloor: 400000,
          ),
          details: sorted.reversed
              .map(
                (item) => MetricDetail(
                  title: _monthLabel(item.month),
                  subtitle: 'Cash in ${_currency(item.cashIn)}',
                  trailing: _currency(item.balance),
                ),
              )
              .toList(),
        ),
        DashboardMetric(
          title: 'Monthly Burn Rate',
          value: _currency(burnRate),
          subtitle: 'Average monthly cash outflow',
          health: burnRate <= 120000
              ? MetricHealth.good
              : burnRate <= 200000
              ? MetricHealth.warning
              : MetricHealth.critical,
          details: sorted.reversed
              .map(
                (item) => MetricDetail(
                  title: _monthLabel(item.month),
                  subtitle: 'Outflow',
                  trailing: _currency(item.cashOut),
                ),
              )
              .toList(),
        ),
        DashboardMetric(
          title: 'Runway',
          value: '${runway.toStringAsFixed(1)} months',
          subtitle: 'Balance divided by burn rate',
          health: runway >= 6
              ? MetricHealth.good
              : runway >= 3
              ? MetricHealth.warning
              : MetricHealth.critical,
          details: [
            MetricDetail(
              title: 'Current balance',
              subtitle: 'Most recent financial snapshot',
              trailing: _currency(latest?.balance ?? 0),
            ),
            MetricDetail(
              title: 'Average burn',
              subtitle: 'Average cash out per month',
              trailing: _currency(burnRate),
            ),
          ],
        ),
        DashboardMetric(
          title: 'Funding Diversity',
          value: '$diversity sources',
          subtitle: 'Distinct received funding sources',
          health: diversity >= 5
              ? MetricHealth.good
              : diversity >= 3
              ? MetricHealth.warning
              : MetricHealth.critical,
          details: funding
              .where((item) => item.amountReceived > 0)
              .map(
                (item) => MetricDetail(
                  title: item.entityName,
                  subtitle: item.opportunityName,
                  trailing: _currency(item.amountReceived),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  static List<double> _funnel(List<FundingOpportunity> funding) {
    final applied = funding.fold<double>(
      0,
      (sum, item) => sum + item.amountApplied,
    );
    final approved = funding.fold<double>(
      0,
      (sum, item) => sum + item.amountApproved,
    );
    final received = funding.fold<double>(
      0,
      (sum, item) => sum + item.amountReceived,
    );
    return [applied, approved, received];
  }

  static List<double> _cashTrend(List<FinancialRecord> financials) {
    final sorted = [...financials]
      ..sort(
        (a, b) =>
            (a.month ?? DateTime(1900)).compareTo(b.month ?? DateTime(1900)),
      );
    return sorted
        .take(max(0, sorted.length))
        .map((item) => item.balance)
        .toList();
  }

  static List<double> _fundingTrend(List<FundingOpportunity> funding) {
    final sorted = [...funding]
      ..sort(
        (a, b) => (a.expectedCloseDate ?? DateTime(1900)).compareTo(
          b.expectedCloseDate ?? DateTime(1900),
        ),
      );
    return sorted.map((item) => item.amountReceived).toList();
  }

  static List<AlertItem> _alerts(
    List<FundingOpportunity> funding,
    List<Partnership> partnerships,
  ) {
    final now = DateTime.now();
    final alerts = <AlertItem>[];

    for (final item in funding) {
      if (item.expectedCloseDate != null &&
          item.expectedCloseDate!.isBefore(now) &&
          item.status != 'received') {
        alerts.add(
          AlertItem(
            title: 'Overdue funding opportunity',
            message:
                '${item.opportunityName} for ${item.entityName} is overdue.',
            health: MetricHealth.critical,
          ),
        );
      }
    }

    for (final item in partnerships) {
      if (item.status == 'active' && item.engagementLevel == 'low') {
        alerts.add(
          AlertItem(
            title: 'Low partner engagement',
            message: '${item.partnerName} needs follow-up from ${item.owner}.',
            health: MetricHealth.warning,
          ),
        );
      }
    }

    return alerts.take(6).toList();
  }

  static double _engagementScore(String value) {
    switch (value) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      default:
        return 1;
    }
  }

  static MetricHealth _percentageHealth(
    double value, {
    required double warningFloor,
    required double goodFloor,
  }) {
    if (value >= goodFloor) {
      return MetricHealth.good;
    }
    if (value >= warningFloor) {
      return MetricHealth.warning;
    }
    return MetricHealth.critical;
  }

  static MetricHealth _moneyHealth(
    double value, {
    required double warningFloor,
    required double goodFloor,
  }) {
    if (value >= goodFloor) {
      return MetricHealth.good;
    }
    if (value >= warningFloor) {
      return MetricHealth.warning;
    }
    return MetricHealth.critical;
  }

  static String _currency(double value) {
    return 'R${value.toStringAsFixed(0)}';
  }

  static String _monthLabel(DateTime? value) {
    if (value == null) {
      return 'Unknown month';
    }

    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[value.month - 1]} ${value.year}';
  }
}
