import 'package:flutter_test/flutter_test.dart';
import 'package:usapho_dashboard/logic/dashboard_calculations.dart';
import 'package:usapho_dashboard/models/campaign_record.dart';
import 'package:usapho_dashboard/models/financial_record.dart';
import 'package:usapho_dashboard/models/funding_opportunity.dart';
import 'package:usapho_dashboard/models/partnership.dart';
import 'package:usapho_dashboard/models/program_record.dart';

void main() {
  test('funding metrics calculate secured, pipeline, and conversion', () {
    final overview = DashboardCalculations.buildOverview(
      funding: [
        FundingOpportunity(
          id: '1',
          entityName: 'Partner A',
          opportunityName: 'Grant A',
          amountApplied: 100,
          amountApproved: 50,
          amountReceived: 25,
          status: 'approved',
          probability: 80,
          expectedCloseDate: DateTime(2026, 3, 1),
          owner: 'Alex',
          notes: '',
          createdAt: DateTime(2026, 1, 1),
        ),
        FundingOpportunity(
          id: '2',
          entityName: 'Partner B',
          opportunityName: 'Grant B',
          amountApplied: 200,
          amountApproved: 100,
          amountReceived: 100,
          status: 'received',
          probability: 100,
          expectedCloseDate: DateTime(2026, 4, 1),
          owner: 'Bo',
          notes: '',
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
      partnerships: const [],
      programs: const [],
      campaigns: const [],
      financials: const [],
    );

    final section = overview.sections.first;
    expect(section.metrics[0].value, 'R125');
    expect(section.metrics[1].value, 'R100');
    expect(section.metrics[2].value, '50.0%');
  });

  test('financial metrics calculate burn rate and runway', () {
    final overview = DashboardCalculations.buildOverview(
      funding: const [],
      partnerships: const [],
      programs: const [],
      campaigns: const [],
      financials: [
        FinancialRecord(
          id: '1',
          month: DateTime(2026, 1, 1),
          cashIn: 100000,
          cashOut: 50000,
          balance: 300000,
          committedFunding: 200000,
          createdAt: DateTime(2026, 1, 1),
        ),
        FinancialRecord(
          id: '2',
          month: DateTime(2026, 2, 1),
          cashIn: 80000,
          cashOut: 70000,
          balance: 250000,
          committedFunding: 180000,
          createdAt: DateTime(2026, 2, 1),
        ),
      ],
    );

    final section = overview.sections.last;
    expect(section.metrics[1].value, 'R60000');
    expect(section.metrics[2].value, '4.2 months');
  });

  test('alerts are generated for overdue funding and low engagement', () {
    final overview = DashboardCalculations.buildOverview(
      funding: [
        FundingOpportunity(
          id: '1',
          entityName: 'Partner A',
          opportunityName: 'Late Grant',
          amountApplied: 100,
          amountApproved: 0,
          amountReceived: 0,
          status: 'submitted',
          probability: 40,
          expectedCloseDate: DateTime(2025, 1, 1),
          owner: 'Alex',
          notes: '',
          createdAt: DateTime(2025, 1, 1),
        ),
      ],
      partnerships: [
        Partnership(
          id: '1',
          partnerName: 'Partner X',
          type: 'corporate',
          status: 'active',
          engagementLevel: 'low',
          lastInteractionDate: DateTime(2026, 1, 1),
          activityCount: 1,
          owner: 'Bo',
          notes: '',
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
      programs: const [],
      campaigns: const [],
      financials: const [],
    );

    expect(overview.alerts.length, 2);
  });

  test('marketing metrics calculate engagement rate and leads', () {
    final overview = DashboardCalculations.buildOverview(
      funding: const [],
      partnerships: const [],
      programs: [
        ProgramRecord(
          id: '1',
          programName: 'Program A',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 2, 1),
          participants: 200,
          completionRate: 80,
          impactScore: 4.2,
          fundingSource: 'Grant',
          programLead: 'Lead',
          status: 'completed',
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
      campaigns: [
        CampaignRecord(
          id: '1',
          campaignName: 'Spring Appeal',
          channel: 'Email',
          reach: 1000,
          engagement: 50,
          leadsGenerated: 15,
          date: DateTime(2026, 2, 1),
          owner: 'Casey',
          createdAt: DateTime(2026, 2, 1),
        ),
      ],
      financials: const [],
    );

    final marketing = overview.sections[3];
    expect(marketing.metrics[1].value, '5.0%');
    expect(marketing.metrics[3].value, '15');
  });
}
