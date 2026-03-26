import 'package:flutter/material.dart';

import '../models/campaign_record.dart';
import '../models/financial_record.dart';
import '../models/funding_opportunity.dart';
import '../models/partnership.dart';
import '../models/program_record.dart';
import '../services/dashboard_repository.dart';

class DataEntryDialog extends StatelessWidget {
  const DataEntryDialog({
    super.key,
    required this.repository,
    this.initialTab = 0,
    this.fundingOpportunity,
    this.partnership,
    this.program,
    this.campaign,
    this.financial,
  });

  final DashboardRepository repository;
  final int initialTab;
  final FundingOpportunity? fundingOpportunity;
  final Partnership? partnership;
  final ProgramRecord? program;
  final CampaignRecord? campaign;
  final FinancialRecord? financial;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 980,
        height: 760,
        child: DefaultTabController(
          length: 5,
          initialIndex: initialTab,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? 'Edit Entry' : 'Add Operational Data',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Funding'),
                  Tab(text: 'Partnerships'),
                  Tab(text: 'Programs'),
                  Tab(text: 'Campaigns'),
                  Tab(text: 'Financials'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  physics: _isEditing
                      ? const NeverScrollableScrollPhysics()
                      : null,
                  children: [
                    _FundingForm(
                      repository: repository,
                      existing: fundingOpportunity,
                    ),
                    _PartnershipForm(
                      repository: repository,
                      existing: partnership,
                    ),
                    _ProgramForm(repository: repository, existing: program),
                    _CampaignForm(repository: repository, existing: campaign),
                    _FinancialForm(repository: repository, existing: financial),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isEditing =>
      fundingOpportunity != null ||
      partnership != null ||
      program != null ||
      campaign != null ||
      financial != null;
}

class _FundingForm extends StatefulWidget {
  const _FundingForm({required this.repository, this.existing});

  final DashboardRepository repository;
  final FundingOpportunity? existing;

  @override
  State<_FundingForm> createState() => _FundingFormState();
}

class _FundingFormState extends State<_FundingForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _entityController;
  late final TextEditingController _opportunityController;
  late final TextEditingController _appliedController;
  late final TextEditingController _approvedController;
  late final TextEditingController _receivedController;
  late final TextEditingController _probabilityController;
  late final TextEditingController _ownerController;
  late final TextEditingController _notesController;
  late final TextEditingController _closeDateController;
  late String _status;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _entityController = TextEditingController(text: existing?.entityName ?? '');
    _opportunityController = TextEditingController(
      text: existing?.opportunityName ?? '',
    );
    _appliedController = TextEditingController(
      text: _numberText(existing?.amountApplied),
    );
    _approvedController = TextEditingController(
      text: _numberText(existing?.amountApproved),
    );
    _receivedController = TextEditingController(
      text: _numberText(existing?.amountReceived),
    );
    _probabilityController = TextEditingController(
      text: _numberText(existing?.probability),
    );
    _ownerController = TextEditingController(text: existing?.owner ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _closeDateController = TextEditingController(
      text: _dateText(existing?.expectedCloseDate),
    );
    _status = existing?.status ?? 'pipeline';
  }

  @override
  void dispose() {
    _entityController.dispose();
    _opportunityController.dispose();
    _appliedController.dispose();
    _approvedController.dispose();
    _receivedController.dispose();
    _probabilityController.dispose();
    _ownerController.dispose();
    _notesController.dispose();
    _closeDateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = FundingOpportunity(
      id: widget.existing?.id ?? '',
      entityName: _entityController.text.trim(),
      opportunityName: _opportunityController.text.trim(),
      amountApplied: double.tryParse(_appliedController.text) ?? 0,
      amountApproved: double.tryParse(_approvedController.text) ?? 0,
      amountReceived: double.tryParse(_receivedController.text) ?? 0,
      status: _status,
      probability: double.tryParse(_probabilityController.text) ?? 0,
      expectedCloseDate: _parseDate(_closeDateController.text),
      owner: _ownerController.text.trim(),
      notes: _notesController.text.trim(),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (widget.existing == null) {
      await widget.repository.addFundingOpportunity(item);
    } else {
      await widget.repository.updateFundingOpportunity(item);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _FormScaffold(
      title: 'Track fundraising opportunities',
      description:
          'Capture pipeline, approved amounts, and received funds in one place.',
      child: Form(
        key: _formKey,
        child: _FormGrid(
          children: [
            _requiredField(
              _entityController,
              'Entity Name',
              info:
                  'The organization or donor you are engaging for this opportunity.',
            ),
            _requiredField(
              _opportunityController,
              'Opportunity Name',
              info:
                  'A short label for the grant, proposal, or funding opportunity.',
            ),
            _numberField(
              _appliedController,
              'Amount Applied',
              info: 'The value requested from the donor or funder.',
            ),
            _numberField(
              _approvedController,
              'Amount Approved',
              info: 'The amount formally approved so far, if any.',
            ),
            _numberField(
              _receivedController,
              'Amount Received',
              info:
                  'The money that has actually been received into the account.',
            ),
            _dropdownField<String>(
              label: 'Status',
              info:
                  'Where this opportunity currently sits in the fundraising process.',
              value: _status,
              items: const [
                DropdownMenuItem(value: 'pipeline', child: Text('Pipeline')),
                DropdownMenuItem(value: 'submitted', child: Text('Submitted')),
                DropdownMenuItem(value: 'approved', child: Text('Approved')),
                DropdownMenuItem(value: 'received', child: Text('Received')),
                DropdownMenuItem(value: 'declined', child: Text('Declined')),
              ],
              onChanged: (value) =>
                  setState(() => _status = value ?? 'pipeline'),
            ),
            _numberField(
              _probabilityController,
              'Probability (%)',
              info:
                  'Your best estimate of how likely the opportunity is to close successfully.',
            ),
            _requiredField(
              _ownerController,
              'Owner',
              info: 'The person responsible for managing this opportunity.',
            ),
            _dateField(
              _closeDateController,
              'Expected Close Date',
              info:
                  'The date you expect a decision or payment milestone to happen.',
            ),
            _textAreaField(
              _notesController,
              'Notes',
              info:
                  'Any context, history, or next-step notes for the opportunity.',
            ),
            _submitButton(
              _submit,
              widget.existing == null
                  ? 'Save Funding Opportunity'
                  : 'Update Funding Opportunity',
            ),
          ],
        ),
      ),
    );
  }
}

class _PartnershipForm extends StatefulWidget {
  const _PartnershipForm({required this.repository, this.existing});

  final DashboardRepository repository;
  final Partnership? existing;

  @override
  State<_PartnershipForm> createState() => _PartnershipFormState();
}

class _PartnershipFormState extends State<_PartnershipForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _partnerController;
  late final TextEditingController _activityController;
  late final TextEditingController _ownerController;
  late final TextEditingController _notesController;
  late final TextEditingController _lastInteractionController;
  late String _type;
  late String _status;
  late String _engagement;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _partnerController = TextEditingController(
      text: existing?.partnerName ?? '',
    );
    _activityController = TextEditingController(
      text: existing == null ? '' : existing.activityCount.toString(),
    );
    _ownerController = TextEditingController(text: existing?.owner ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _lastInteractionController = TextEditingController(
      text: _dateText(existing?.lastInteractionDate),
    );
    _type = existing?.type ?? 'corporate';
    _status = existing?.status ?? 'active';
    _engagement = existing?.engagementLevel ?? 'medium';
  }

  @override
  void dispose() {
    _partnerController.dispose();
    _activityController.dispose();
    _ownerController.dispose();
    _notesController.dispose();
    _lastInteractionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = Partnership(
      id: widget.existing?.id ?? '',
      partnerName: _partnerController.text.trim(),
      type: _type,
      status: _status,
      engagementLevel: _engagement,
      lastInteractionDate: _parseDate(_lastInteractionController.text),
      activityCount: int.tryParse(_activityController.text) ?? 0,
      owner: _ownerController.text.trim(),
      notes: _notesController.text.trim(),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (widget.existing == null) {
      await widget.repository.addPartnership(item);
    } else {
      await widget.repository.updatePartnership(item);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _FormScaffold(
      title: 'Capture partnerships',
      description: 'Keep partner relationship status and engagement visible.',
      child: Form(
        key: _formKey,
        child: _FormGrid(
          children: [
            _requiredField(
              _partnerController,
              'Partner Name',
              info: 'The organization or institution you are working with.',
            ),
            _dropdownField<String>(
              label: 'Type',
              info: 'What kind of partner this is.',
              value: _type,
              items: const [
                DropdownMenuItem(value: 'corporate', child: Text('Corporate')),
                DropdownMenuItem(value: 'ngo', child: Text('NGO')),
                DropdownMenuItem(
                  value: 'government',
                  child: Text('Government'),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _type = value ?? 'corporate'),
            ),
            _dropdownField<String>(
              label: 'Status',
              info: 'Whether the partner is active or still a prospect.',
              value: _status,
              items: const [
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'prospect', child: Text('Prospect')),
              ],
              onChanged: (value) => setState(() => _status = value ?? 'active'),
            ),
            _dropdownField<String>(
              label: 'Engagement Level',
              info:
                  'A simple view of how warm, responsive, and involved the partner is.',
              value: _engagement,
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (value) =>
                  setState(() => _engagement = value ?? 'medium'),
            ),
            _dateField(
              _lastInteractionController,
              'Last Interaction Date',
              info: 'The last meaningful meeting, call, or touchpoint.',
            ),
            _numberField(
              _activityController,
              'Activity Count',
              wholeNumbers: true,
              info: 'How many initiatives, meetings, or activities are logged.',
            ),
            _requiredField(
              _ownerController,
              'Owner',
              info: 'The person responsible for managing this relationship.',
            ),
            _textAreaField(
              _notesController,
              'Notes',
              info: 'Any context or agreed next steps for this partner.',
            ),
            _submitButton(
              _submit,
              widget.existing == null
                  ? 'Save Partnership'
                  : 'Update Partnership',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramForm extends StatefulWidget {
  const _ProgramForm({required this.repository, this.existing});

  final DashboardRepository repository;
  final ProgramRecord? existing;

  @override
  State<_ProgramForm> createState() => _ProgramFormState();
}

class _ProgramFormState extends State<_ProgramForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  late final TextEditingController _participantsController;
  late final TextEditingController _completionController;
  late final TextEditingController _impactController;
  late final TextEditingController _fundingSourceController;
  late final TextEditingController _leadController;
  late String _status;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.programName ?? '');
    _startController = TextEditingController(
      text: _dateText(existing?.startDate),
    );
    _endController = TextEditingController(text: _dateText(existing?.endDate));
    _participantsController = TextEditingController(
      text: existing == null ? '' : existing.participants.toString(),
    );
    _completionController = TextEditingController(
      text: _numberText(existing?.completionRate),
    );
    _impactController = TextEditingController(
      text: _numberText(existing?.impactScore),
    );
    _fundingSourceController = TextEditingController(
      text: existing?.fundingSource ?? '',
    );
    _leadController = TextEditingController(text: existing?.programLead ?? '');
    _status = existing?.status ?? 'planned';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startController.dispose();
    _endController.dispose();
    _participantsController.dispose();
    _completionController.dispose();
    _impactController.dispose();
    _fundingSourceController.dispose();
    _leadController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = ProgramRecord(
      id: widget.existing?.id ?? '',
      programName: _nameController.text.trim(),
      startDate: _parseDate(_startController.text),
      endDate: _parseDate(_endController.text),
      participants: int.tryParse(_participantsController.text) ?? 0,
      completionRate: double.tryParse(_completionController.text) ?? 0,
      impactScore: double.tryParse(_impactController.text) ?? 0,
      fundingSource: _fundingSourceController.text.trim(),
      programLead: _leadController.text.trim(),
      status: _status,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (widget.existing == null) {
      await widget.repository.addProgram(item);
    } else {
      await widget.repository.updateProgram(item);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _FormScaffold(
      title: 'Track program delivery',
      description: 'Capture reach, completion, and impact from delivery teams.',
      child: Form(
        key: _formKey,
        child: _FormGrid(
          children: [
            _requiredField(
              _nameController,
              'Program Name',
              info: 'The name of the project or intervention being delivered.',
            ),
            _dateField(
              _startController,
              'Start Date',
              info: 'When the program begins.',
            ),
            _dateField(
              _endController,
              'End Date',
              info: 'When the program is expected to end or ended.',
            ),
            _numberField(
              _participantsController,
              'Participants',
              wholeNumbers: true,
              info: 'How many beneficiaries or participants were reached.',
            ),
            _numberField(
              _completionController,
              'Completion Rate (%)',
              info: 'The percentage of participants or activities completed.',
            ),
            _numberField(
              _impactController,
              'Impact Score',
              info: 'A simple score used internally to reflect program impact.',
            ),
            _requiredField(
              _fundingSourceController,
              'Funding Source',
              info: 'The grant, donor, or budget line funding this program.',
            ),
            _requiredField(
              _leadController,
              'Program Lead',
              info: 'The staff member accountable for delivery.',
            ),
            _dropdownField<String>(
              label: 'Status',
              info: 'The current delivery stage of the program.',
              value: _status,
              items: const [
                DropdownMenuItem(value: 'planned', child: Text('Planned')),
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
              ],
              onChanged: (value) =>
                  setState(() => _status = value ?? 'planned'),
            ),
            _submitButton(
              _submit,
              widget.existing == null ? 'Save Program' : 'Update Program',
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignForm extends StatefulWidget {
  const _CampaignForm({required this.repository, this.existing});

  final DashboardRepository repository;
  final CampaignRecord? existing;

  @override
  State<_CampaignForm> createState() => _CampaignFormState();
}

class _CampaignFormState extends State<_CampaignForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _channelController;
  late final TextEditingController _reachController;
  late final TextEditingController _engagementController;
  late final TextEditingController _leadsController;
  late final TextEditingController _dateController;
  late final TextEditingController _ownerController;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.campaignName ?? '');
    _channelController = TextEditingController(text: existing?.channel ?? '');
    _reachController = TextEditingController(
      text: existing == null ? '' : existing.reach.toString(),
    );
    _engagementController = TextEditingController(
      text: existing == null ? '' : existing.engagement.toString(),
    );
    _leadsController = TextEditingController(
      text: existing == null ? '' : existing.leadsGenerated.toString(),
    );
    _dateController = TextEditingController(text: _dateText(existing?.date));
    _ownerController = TextEditingController(text: existing?.owner ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _channelController.dispose();
    _reachController.dispose();
    _engagementController.dispose();
    _leadsController.dispose();
    _dateController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = CampaignRecord(
      id: widget.existing?.id ?? '',
      campaignName: _nameController.text.trim(),
      channel: _channelController.text.trim(),
      reach: int.tryParse(_reachController.text) ?? 0,
      engagement: int.tryParse(_engagementController.text) ?? 0,
      leadsGenerated: int.tryParse(_leadsController.text) ?? 0,
      date: _parseDate(_dateController.text),
      owner: _ownerController.text.trim(),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (widget.existing == null) {
      await widget.repository.addCampaign(item);
    } else {
      await widget.repository.updateCampaign(item);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _FormScaffold(
      title: 'Add campaign performance',
      description: 'Log reach, engagement, and generated leads by channel.',
      child: Form(
        key: _formKey,
        child: _FormGrid(
          children: [
            _requiredField(
              _nameController,
              'Campaign Name',
              info: 'The public or internal name of the campaign.',
            ),
            _requiredField(
              _channelController,
              'Channel',
              info: 'Where the campaign ran, such as email or social media.',
            ),
            _numberField(
              _reachController,
              'Reach',
              wholeNumbers: true,
              info: 'The number of people who saw the campaign.',
            ),
            _numberField(
              _engagementController,
              'Engagement',
              wholeNumbers: true,
              info:
                  'The total number of interactions such as clicks or comments.',
            ),
            _numberField(
              _leadsController,
              'Leads Generated',
              wholeNumbers: true,
              info: 'Potential donors, supporters, or contacts captured.',
            ),
            _dateField(
              _dateController,
              'Campaign Date',
              info: 'The date this campaign ran or launched.',
            ),
            _requiredField(
              _ownerController,
              'Owner',
              info: 'The person responsible for this campaign.',
            ),
            _submitButton(
              _submit,
              widget.existing == null ? 'Save Campaign' : 'Update Campaign',
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialForm extends StatefulWidget {
  const _FinancialForm({required this.repository, this.existing});

  final DashboardRepository repository;
  final FinancialRecord? existing;

  @override
  State<_FinancialForm> createState() => _FinancialFormState();
}

class _FinancialFormState extends State<_FinancialForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _monthController;
  late final TextEditingController _cashInController;
  late final TextEditingController _cashOutController;
  late final TextEditingController _balanceController;
  late final TextEditingController _committedController;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _monthController = TextEditingController(text: _dateText(existing?.month));
    _cashInController = TextEditingController(
      text: _numberText(existing?.cashIn),
    );
    _cashOutController = TextEditingController(
      text: _numberText(existing?.cashOut),
    );
    _balanceController = TextEditingController(
      text: _numberText(existing?.balance),
    );
    _committedController = TextEditingController(
      text: _numberText(existing?.committedFunding),
    );
  }

  @override
  void dispose() {
    _monthController.dispose();
    _cashInController.dispose();
    _cashOutController.dispose();
    _balanceController.dispose();
    _committedController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = FinancialRecord(
      id: widget.existing?.id ?? '',
      month: _parseDate(_monthController.text),
      cashIn: double.tryParse(_cashInController.text) ?? 0,
      cashOut: double.tryParse(_cashOutController.text) ?? 0,
      balance: double.tryParse(_balanceController.text) ?? 0,
      committedFunding: double.tryParse(_committedController.text) ?? 0,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (widget.existing == null) {
      await widget.repository.addFinancial(item);
    } else {
      await widget.repository.updateFinancial(item);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _FormScaffold(
      title: 'Log financial sustainability data',
      description: 'Capture monthly cash movement and committed funding.',
      child: Form(
        key: _formKey,
        child: _FormGrid(
          children: [
            _dateField(
              _monthController,
              'Month',
              info: 'Use the month this financial snapshot represents.',
            ),
            _numberField(
              _cashInController,
              'Cash In',
              info: 'The total incoming cash for the month.',
            ),
            _numberField(
              _cashOutController,
              'Cash Out',
              info: 'The total outgoing cash for the month.',
            ),
            _numberField(
              _balanceController,
              'Balance',
              info: 'The closing cash balance at month end.',
            ),
            _numberField(
              _committedController,
              'Committed Funding',
              info: 'Funding confirmed but not yet fully received.',
            ),
            _submitButton(
              _submit,
              widget.existing == null
                  ? 'Save Financial Record'
                  : 'Update Financial Record',
            ),
          ],
        ),
      ),
    );
  }
}

class _FormScaffold extends StatelessWidget {
  const _FormScaffold({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _FormGrid extends StatelessWidget {
  const _FormGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children
          .map((child) => SizedBox(width: 280, child: child))
          .toList(),
    );
  }
}

TextFormField _requiredField(
  TextEditingController controller,
  String label, {
  required String info,
}) {
  return TextFormField(
    controller: controller,
    decoration: _inputDecoration(label, info),
    validator: (value) =>
        value == null || value.trim().isEmpty ? '$label is required' : null,
  );
}

TextFormField _numberField(
  TextEditingController controller,
  String label, {
  bool wholeNumbers = false,
  required String info,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: _inputDecoration(label, info),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return '$label is required';
      }
      final parsed = num.tryParse(value);
      if (parsed == null) {
        return 'Enter a valid number';
      }
      if (wholeNumbers && parsed % 1 != 0) {
        return 'Enter a whole number';
      }
      return null;
    },
  );
}

TextFormField _dateField(
  TextEditingController controller,
  String label, {
  required String info,
}) {
  return TextFormField(
    controller: controller,
    decoration: _inputDecoration(label, info).copyWith(hintText: 'YYYY-MM-DD'),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return '$label is required';
      }
      return _parseDate(value) == null ? 'Use YYYY-MM-DD' : null;
    },
  );
}

TextFormField _textAreaField(
  TextEditingController controller,
  String label, {
  required String info,
}) {
  return TextFormField(
    controller: controller,
    maxLines: 4,
    decoration: _inputDecoration(label, info),
  );
}

Widget _submitButton(VoidCallback onPressed, String label) {
  return Align(
    alignment: Alignment.centerLeft,
    child: ElevatedButton(onPressed: onPressed, child: Text(label)),
  );
}

DropdownButtonFormField<T> _dropdownField<T>({
  required String label,
  required String info,
  required T value,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
}) {
  return DropdownButtonFormField<T>(
    initialValue: value,
    decoration: _inputDecoration(label, info),
    items: items,
    onChanged: onChanged,
  );
}

InputDecoration _inputDecoration(String label, String info) {
  return InputDecoration(
    labelText: label,
    suffixIcon: Tooltip(
      message: info,
      child: const Padding(
        padding: EdgeInsets.only(right: 8),
        child: Icon(Icons.info_outline, size: 18),
      ),
    ),
  );
}

DateTime? _parseDate(String value) {
  try {
    return DateTime.parse(value.trim());
  } catch (_) {
    return null;
  }
}

String _dateText(DateTime? value) {
  if (value == null) {
    return '';
  }
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String _numberText(num? value) {
  if (value == null) {
    return '';
  }
  return value % 1 == 0 ? value.toStringAsFixed(0) : value.toString();
}
