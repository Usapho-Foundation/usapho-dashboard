import 'package:cloud_firestore/cloud_firestore.dart';

class FundingOpportunity {
  FundingOpportunity({
    required this.id,
    // Legacy fields (for backward compatibility)
    required this.entityName,
    required this.opportunityName,
    required this.amountApplied,
    required this.amountApproved,
    required this.amountReceived,
    required this.status,
    required this.probability,
    required this.expectedCloseDate,
    required this.owner,
    required this.notes,
    required this.createdAt,
    // New spreadsheet-aligned fields
    required this.type,
    required this.funderName,
    required this.monthly,
    required this.quarterly,
    required this.annually,
    required this.fundingPeriod,
    required this.cohortTarget,
    required this.cohortActual,
    required this.amountAppliedFor,
    required this.amountReceivedToDate,
    required this.target,
    required this.actual,
    required this.dateSubmitted,
    required this.stakeholderContact,
    required this.personResponsible,
    required this.comments,
    required this.update,
    required this.forecastedIncome,
  });

  // Legacy fields
  final String id;
  final String entityName;
  final String opportunityName;
  final double amountApplied;
  final double amountApproved;
  final double amountReceived;
  final String status;
  final double probability;
  final DateTime? expectedCloseDate;
  final String owner;
  final String notes;
  final DateTime? createdAt;

  // New spreadsheet-aligned fields
  final String type; // "restricted" | "unrestricted" | "proposal" | "income_activity" | "forecast"
  final String funderName;
  final double monthly;
  final double quarterly;
  final double annually;
  final String fundingPeriod;
  final int cohortTarget;
  final int cohortActual;
  final double amountAppliedFor;
  final double amountReceivedToDate;
  final double target;
  final double actual;
  final DateTime? dateSubmitted;
  final String stakeholderContact;
  final String personResponsible;
  final String comments;
  final String update;
  final double forecastedIncome;

  factory FundingOpportunity.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return FundingOpportunity(
      id: id,
      // Legacy fields with defaults
      entityName: data['entityName'] ?? '',
      opportunityName: data['opportunityName'] ?? '',
      amountApplied: (data['amountApplied'] ?? 0).toDouble(),
      amountApproved: (data['amountApproved'] ?? 0).toDouble(),
      amountReceived: (data['amountReceived'] ?? 0).toDouble(),
      status: data['status'] ?? 'pipeline',
      probability: (data['probability'] ?? 0).toDouble(),
      expectedCloseDate: (data['expectedCloseDate'] as Timestamp?)?.toDate(),
      owner: data['owner'] ?? 'Unassigned',
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      // New spreadsheet-aligned fields with defaults
      type: data['type'] ?? 'restricted',
      funderName: data['funderName'] ?? '',
      monthly: (data['monthly'] ?? 0).toDouble(),
      quarterly: (data['quarterly'] ?? 0).toDouble(),
      annually: (data['annually'] ?? 0).toDouble(),
      fundingPeriod: data['fundingPeriod'] ?? '',
      cohortTarget: data['cohortTarget'] ?? 0,
      cohortActual: data['cohortActual'] ?? 0,
      amountAppliedFor: (data['amountAppliedFor'] ?? 0).toDouble(),
      amountReceivedToDate: (data['amountReceivedToDate'] ?? 0).toDouble(),
      target: (data['target'] ?? 0).toDouble(),
      actual: (data['actual'] ?? 0).toDouble(),
      dateSubmitted: (data['dateSubmitted'] as Timestamp?)?.toDate(),
      stakeholderContact: data['stakeholderContact'] ?? '',
      personResponsible: data['personResponsible'] ?? '',
      comments: data['comments'] ?? '',
      update: data['update'] ?? '',
      forecastedIncome: (data['forecastedIncome'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // Legacy fields
      'entityName': entityName,
      'opportunityName': opportunityName,
      'amountApplied': amountApplied,
      'amountApproved': amountApproved,
      'amountReceived': amountReceived,
      'status': status,
      'probability': probability,
      'expectedCloseDate': expectedCloseDate == null
          ? null
          : Timestamp.fromDate(expectedCloseDate!),
      'owner': owner,
      'notes': notes,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      // New spreadsheet-aligned fields
      'type': type,
      'funderName': funderName,
      'monthly': monthly,
      'quarterly': quarterly,
      'annually': annually,
      'fundingPeriod': fundingPeriod,
      'cohortTarget': cohortTarget,
      'cohortActual': cohortActual,
      'amountAppliedFor': amountAppliedFor,
      'amountReceivedToDate': amountReceivedToDate,
      'target': target,
      'actual': actual,
      'dateSubmitted': dateSubmitted == null
          ? null
          : Timestamp.fromDate(dateSubmitted!),
      'stakeholderContact': stakeholderContact,
      'personResponsible': personResponsible,
      'comments': comments,
      'update': update,
      'forecastedIncome': forecastedIncome,
    };
  }
}
