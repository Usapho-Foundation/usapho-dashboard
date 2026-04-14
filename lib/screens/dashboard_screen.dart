import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../logic/dashboard_calculations.dart';
import '../models/campaign_record.dart';
import '../models/dashboard_filter.dart';
import '../models/financial_record.dart';
import '../models/funding_opportunity.dart';
import '../models/partnership.dart';
import '../models/program_record.dart';
import '../services/dashboard_repository.dart';
import '../services/feedback_service.dart';
import '../widgets/chart_card.dart';
import '../widgets/data_entry_dialog.dart';
import '../widgets/filter_bar.dart';
import '../widgets/kpi_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardRepository _repository = DashboardRepository();
  final FeedbackService _feedbackService = FeedbackService();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  DashboardFilter _filter = const DashboardFilter();
  List<FundingOpportunity> _funding = const [];
  List<Partnership> _partnerships = const [];
  List<ProgramRecord> _programs = const [];
  List<CampaignRecord> _campaigns = const [];
  List<FinancialRecord> _financials = const [];
  bool _isReady = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _subscriptions.addAll([
      _repository.watchFundingOpportunities().listen(
        (data) => _setData(funding: data),
        onError: _setError,
      ),
      _repository.watchPartnerships().listen(
        (data) => _setData(partnerships: data),
        onError: _setError,
      ),
      _repository.watchPrograms().listen(
        (data) => _setData(programs: data),
        onError: _setError,
      ),
      _repository.watchCampaigns().listen(
        (data) => _setData(campaigns: data),
        onError: _setError,
      ),
      _repository.watchFinancials().listen(
        (data) => _setData(financials: data),
        onError: _setError,
      ),
    ]);
  }

  void _setData({
    List<FundingOpportunity>? funding,
    List<Partnership>? partnerships,
    List<ProgramRecord>? programs,
    List<CampaignRecord>? campaigns,
    List<FinancialRecord>? financials,
  }) {
    if (!mounted) {
      return;
    }

    setState(() {
      _funding = funding ?? _funding;
      _partnerships = partnerships ?? _partnerships;
      _programs = programs ?? _programs;
      _campaigns = campaigns ?? _campaigns;
      _financials = financials ?? _financials;
      _isReady = true;
      _error = null;
    });
  }

  void _setError(Object error) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isReady = true;
      _error = error;
    });
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void _openDataEntryDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => DataEntryDialog(repository: _repository),
    );
  }

  Future<void> _openFeedbackDialog() async {
    final feedbackController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Feedback'),
        content: TextField(
          controller: feedbackController,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Add feedback or suggestions for the dashboard',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _openFeedbackDialog,
            icon: const Icon(Icons.feedback_outlined, color: Colors.black87),
            label: const Text(
              'Feedback',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final feedback = feedbackController.text.trim();
              if (feedback.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please add feedback before submitting.'),
                  ),
                );
                return;
              }

              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser == null) {
                debugPrint(
                  'Feedback submission failed: no authenticated user.',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Unable to submit feedback. Please sign in and try again.',
                    ),
                  ),
                );
                return;
              }

              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                await _feedbackService.saveFeedback(
                  userId: currentUser.uid,
                  feedbackText: feedback,
                );
                if (!mounted) {
                  return;
                }

                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Thanks! Your feedback has been captured for review.',
                    ),
                  ),
                );
              } on FirebaseException catch (error) {
                debugPrint('Feedback submission failed: $error');
                if (!mounted) {
                  return;
                }
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Unable to submit feedback right now. ${error.message ?? 'Please try again later.'}',
                    ),
                  ),
                );
              } catch (error) {
                debugPrint('Feedback submission failed: $error');
                if (!mounted) {
                  return;
                }
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Unable to submit feedback right now. Please try again later.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    feedbackController.dispose();
  }

  void _openEditFunding(FundingOpportunity item) {
    showDialog<void>(
      context: context,
      builder: (_) => DataEntryDialog(
        repository: _repository,
        initialTab: 0,
        fundingOpportunity: item,
      ),
    );
  }

  void _openEditPartnership(Partnership item) {
    showDialog<void>(
      context: context,
      builder: (_) => DataEntryDialog(
        repository: _repository,
        initialTab: 1,
        partnership: item,
      ),
    );
  }

  void _openEditProgram(ProgramRecord item) {
    showDialog<void>(
      context: context,
      builder: (_) => DataEntryDialog(
        repository: _repository,
        initialTab: 2,
        program: item,
      ),
    );
  }

  void _openEditCampaign(CampaignRecord item) {
    showDialog<void>(
      context: context,
      builder: (_) => DataEntryDialog(
        repository: _repository,
        initialTab: 3,
        campaign: item,
      ),
    );
  }

  void _openEditFinancial(FinancialRecord item) {
    showDialog<void>(
      context: context,
      builder: (_) => DataEntryDialog(
        repository: _repository,
        initialTab: 4,
        financial: item,
      ),
    );
  }

  Future<void> _confirmDelete({
    required String title,
    required Future<void> Function() onDelete,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Delete "$title"? This cannot be undone.'),
        actions: [
          TextButton.icon(
            onPressed: _openFeedbackDialog,
            icon: const Icon(Icons.feedback_outlined, color: Colors.black87),
            label: const Text(
              'Feedback',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await onDelete();
    }
  }

  void _openMetricDetails(DashboardMetric metric) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SizedBox(
        height: 520,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(metric.subtitle),
              const SizedBox(height: 18),
              Expanded(
                child: metric.details.isEmpty
                    ? const Center(
                        child: Text('No matching records in this view.'),
                      )
                    : ListView.separated(
                        itemBuilder: (context, index) {
                          final detail = metric.details[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(detail.title),
                            subtitle: Text(detail.subtitle),
                            trailing: Text(detail.trailing),
                          );
                        },
                        separatorBuilder: (_, index) => const Divider(),
                        itemCount: metric.details.length,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FundingOpportunity> get _filteredFunding {
    return _funding.where(_matchesFunding).toList();
  }

  List<Partnership> get _filteredPartnerships {
    return _partnerships.where(_matchesPartnership).toList();
  }

  List<ProgramRecord> get _filteredPrograms {
    return _programs.where(_matchesProgram).toList();
  }

  List<CampaignRecord> get _filteredCampaigns {
    return _campaigns.where(_matchesCampaign).toList();
  }

  List<FinancialRecord> get _filteredFinancials {
    return _financials.where(_matchesFinancial).toList();
  }

  bool _matchesFunding(FundingOpportunity item) {
    return _matches(
      date: item.expectedCloseDate ?? item.createdAt,
      owner: item.owner,
      status: item.status,
      haystack: '${item.entityName} ${item.opportunityName} ${item.notes}'
          .toLowerCase(),
    );
  }

  bool _matchesPartnership(Partnership item) {
    return _matches(
      date: item.lastInteractionDate ?? item.createdAt,
      owner: item.owner,
      status: item.status,
      haystack: '${item.partnerName} ${item.type} ${item.notes}'.toLowerCase(),
    );
  }

  bool _matchesProgram(ProgramRecord item) {
    return _matches(
      date: item.endDate ?? item.startDate ?? item.createdAt,
      owner: item.programLead,
      status: item.status,
      haystack: '${item.programName} ${item.fundingSource} ${item.programLead}'
          .toLowerCase(),
    );
  }

  bool _matchesCampaign(CampaignRecord item) {
    return _matches(
      date: item.date ?? item.createdAt,
      owner: item.owner,
      haystack: '${item.campaignName} ${item.channel} ${item.owner}'
          .toLowerCase(),
    );
  }

  bool _matchesFinancial(FinancialRecord item) {
    return _matches(
      date: item.month ?? item.createdAt,
      haystack: 'financial ${item.balance} ${item.cashIn} ${item.cashOut}',
    );
  }

  bool _matches({
    DateTime? date,
    String? owner,
    String? status,
    required String haystack,
  }) {
    final range = DashboardCalculations.rangeForPreset(
      _filter.datePreset,
      DateTime.now(),
    );
    if (range != null && date != null) {
      if (date.isBefore(range.start) || date.isAfter(range.end)) {
        return false;
      }
    }

    if (_filter.owner != null && owner != _filter.owner) {
      return false;
    }

    if (_filter.status != null && status != _filter.status) {
      return false;
    }

    final query = _filter.search.trim().toLowerCase();
    if (query.isNotEmpty && !haystack.contains(query)) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final owners = {
      ..._funding.map((item) => item.owner),
      ..._partnerships.map((item) => item.owner),
      ..._programs.map((item) => item.programLead),
      ..._campaigns.map((item) => item.owner),
    }.where((value) => value.trim().isNotEmpty).toList()..sort();

    final statuses = {
      ..._funding.map((item) => item.status),
      ..._partnerships.map((item) => item.status),
      ..._programs.map((item) => item.status),
    }.toList()..sort();

    final overview = DashboardCalculations.buildOverview(
      funding: _filteredFunding,
      partnerships: _filteredPartnerships,
      programs: _filteredPrograms,
      campaigns: _filteredCampaigns,
      financials: _filteredFinancials,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/usapho_logo.png', height: 36),
            const SizedBox(width: 12),
            const Expanded(child: Text('Dashboard')),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _openFeedbackDialog,
            icon: const Icon(Icons.feedback_outlined, color: Colors.black87),
            label: const Text(
              'Feedback',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          TextButton.icon(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout, color: Colors.black87),
            label: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          FilledButton.icon(
            onPressed: _openDataEntryDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Data'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: !_isReady
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Something went wrong: $_error'))
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TabBar(
                        isScrollable: true,
                        tabs: [
                          Tab(text: 'Overview'),
                          Tab(text: 'Entries'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth > 1120;

                            return SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                12,
                                24,
                                24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'A simple, live view of fundraising, delivery, and sustainability.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  FilterBar(
                                    filter: _filter,
                                    owners: owners,
                                    statuses: statuses,
                                    onFilterChanged: (value) {
                                      setState(() {
                                        _filter = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  if (overview.alerts.isNotEmpty) ...[
                                    _AlertsPanel(alerts: overview.alerts),
                                    const SizedBox(height: 20),
                                  ],
                                  if (wide)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: ChartCard(
                                            title: 'Funding Funnel',
                                            subtitle:
                                                'Pipeline to approved to received value',
                                            child: FunnelChart(
                                              values: overview.funnelValues,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: ChartCard(
                                            title: 'Cash Balance Trend',
                                            subtitle:
                                                'Recent month-end balance movement',
                                            child: LineTrendChart(
                                              values: overview.cashTrend,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  else ...[
                                    ChartCard(
                                      title: 'Funding Funnel',
                                      subtitle:
                                          'Pipeline to approved to received value',
                                      child: FunnelChart(
                                        values: overview.funnelValues,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ChartCard(
                                      title: 'Cash Balance Trend',
                                      subtitle:
                                          'Recent month-end balance movement',
                                      child: LineTrendChart(
                                        values: overview.cashTrend,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  ...overview.sections.map(
                                    (section) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 18,
                                      ),
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                section.title,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                section.description,
                                                style: const TextStyle(
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              LayoutBuilder(
                                                builder:
                                                    (context, cardConstraints) {
                                                      final columns =
                                                          cardConstraints
                                                                  .maxWidth >
                                                              980
                                                          ? 4
                                                          : cardConstraints
                                                                    .maxWidth >
                                                                620
                                                          ? 2
                                                          : 1;
                                                      final width =
                                                          (cardConstraints
                                                                  .maxWidth -
                                                              (16 *
                                                                  (columns -
                                                                      1))) /
                                                          columns;

                                                      return Wrap(
                                                        spacing: 16,
                                                        runSpacing: 16,
                                                        children: section
                                                            .metrics
                                                            .map(
                                                              (
                                                                metric,
                                                              ) => SizedBox(
                                                                width: width,
                                                                child: KpiCard(
                                                                  metric:
                                                                      metric,
                                                                  onTap: () =>
                                                                      _openMetricDetails(
                                                                        metric,
                                                                      ),
                                                                ),
                                                              ),
                                                            )
                                                            .toList(),
                                                      );
                                                    },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        _EntriesTab(
                          funding: _filteredFunding,
                          partnerships: _filteredPartnerships,
                          programs: _filteredPrograms,
                          campaigns: _filteredCampaigns,
                          financials: _filteredFinancials,
                          onEditFunding: _openEditFunding,
                          onDeleteFunding: (item) => _confirmDelete(
                            title: item.opportunityName,
                            onDelete: () =>
                                _repository.deleteFundingOpportunity(item.id),
                          ),
                          onEditPartnership: _openEditPartnership,
                          onDeletePartnership: (item) => _confirmDelete(
                            title: item.partnerName,
                            onDelete: () =>
                                _repository.deletePartnership(item.id),
                          ),
                          onEditProgram: _openEditProgram,
                          onDeleteProgram: (item) => _confirmDelete(
                            title: item.programName,
                            onDelete: () => _repository.deleteProgram(item.id),
                          ),
                          onEditCampaign: _openEditCampaign,
                          onDeleteCampaign: (item) => _confirmDelete(
                            title: item.campaignName,
                            onDelete: () => _repository.deleteCampaign(item.id),
                          ),
                          onEditFinancial: _openEditFinancial,
                          onDeleteFinancial: (item) => _confirmDelete(
                            title:
                                'Financial record ${item.month?.toIso8601String().split('T').first ?? item.id}',
                            onDelete: () =>
                                _repository.deleteFinancial(item.id),
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

class _AlertsPanel extends StatelessWidget {
  const _AlertsPanel({required this.alerts});

  final List<AlertItem> alerts;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alerts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...alerts.map((alert) {
              final color = switch (alert.health) {
                MetricHealth.good => const Color(0xFF2E7D32),
                MetricHealth.warning => const Color(0xFFED9B00),
                MetricHealth.critical => const Color(0xFFC62828),
                MetricHealth.neutral => const Color(0xFF6B7280),
              };
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 10, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(alert.message),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _EntriesTab extends StatelessWidget {
  const _EntriesTab({
    required this.funding,
    required this.partnerships,
    required this.programs,
    required this.campaigns,
    required this.financials,
    required this.onEditFunding,
    required this.onDeleteFunding,
    required this.onEditPartnership,
    required this.onDeletePartnership,
    required this.onEditProgram,
    required this.onDeleteProgram,
    required this.onEditCampaign,
    required this.onDeleteCampaign,
    required this.onEditFinancial,
    required this.onDeleteFinancial,
  });

  final List<FundingOpportunity> funding;
  final List<Partnership> partnerships;
  final List<ProgramRecord> programs;
  final List<CampaignRecord> campaigns;
  final List<FinancialRecord> financials;
  final ValueChanged<FundingOpportunity> onEditFunding;
  final ValueChanged<FundingOpportunity> onDeleteFunding;
  final ValueChanged<Partnership> onEditPartnership;
  final ValueChanged<Partnership> onDeletePartnership;
  final ValueChanged<ProgramRecord> onEditProgram;
  final ValueChanged<ProgramRecord> onDeleteProgram;
  final ValueChanged<CampaignRecord> onEditCampaign;
  final ValueChanged<CampaignRecord> onDeleteCampaign;
  final ValueChanged<FinancialRecord> onEditFinancial;
  final ValueChanged<FinancialRecord> onDeleteFinancial;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        _EntrySection(
          title: 'Funding Opportunities',
          count: funding.length,
          children: funding
              .map(
                (item) => _EntryTile(
                  title: item.opportunityName,
                  subtitle:
                      '${item.entityName} | ${item.status} | ${item.owner}',
                  trailingText: 'R${item.amountApplied.toStringAsFixed(0)}',
                  onEdit: () => onEditFunding(item),
                  onDelete: () => onDeleteFunding(item),
                ),
              )
              .toList(),
        ),
        _EntrySection(
          title: 'Partnerships',
          count: partnerships.length,
          children: partnerships
              .map(
                (item) => _EntryTile(
                  title: item.partnerName,
                  subtitle: '${item.type} | ${item.status} | ${item.owner}',
                  trailingText: item.engagementLevel,
                  onEdit: () => onEditPartnership(item),
                  onDelete: () => onDeletePartnership(item),
                ),
              )
              .toList(),
        ),
        _EntrySection(
          title: 'Programs',
          count: programs.length,
          children: programs
              .map(
                (item) => _EntryTile(
                  title: item.programName,
                  subtitle: '${item.status} | ${item.programLead}',
                  trailingText: '${item.participants} participants',
                  onEdit: () => onEditProgram(item),
                  onDelete: () => onDeleteProgram(item),
                ),
              )
              .toList(),
        ),
        _EntrySection(
          title: 'Campaigns',
          count: campaigns.length,
          children: campaigns
              .map(
                (item) => _EntryTile(
                  title: item.campaignName,
                  subtitle: '${item.channel} | ${item.owner}',
                  trailingText: '${item.leadsGenerated} leads',
                  onEdit: () => onEditCampaign(item),
                  onDelete: () => onDeleteCampaign(item),
                ),
              )
              .toList(),
        ),
        _EntrySection(
          title: 'Financials',
          count: financials.length,
          children: financials
              .map(
                (item) => _EntryTile(
                  title:
                      item.month?.toIso8601String().split('T').first ??
                      'Financial record',
                  subtitle:
                      'Cash in R${item.cashIn.toStringAsFixed(0)} | Cash out R${item.cashOut.toStringAsFixed(0)}',
                  trailingText: 'R${item.balance.toStringAsFixed(0)}',
                  onEdit: () => onEditFinancial(item),
                  onDelete: () => onDeleteFinancial(item),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _EntrySection extends StatelessWidget {
  const _EntrySection({
    required this.title,
    required this.count,
    required this.children,
  });

  final String title;
  final int count;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title ($count)',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (children.isEmpty)
                const Text('No entries found for the current filters.')
              else
                ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.title,
    required this.subtitle,
    required this.trailingText,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final String trailingText;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(trailingText),
              IconButton(
                tooltip: 'Edit entry',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete entry',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
