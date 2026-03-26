import 'package:cloud_firestore/cloud_firestore.dart';

class FundingOpportunity {
  FundingOpportunity({
    required this.id,
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
  });

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

  factory FundingOpportunity.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return FundingOpportunity(
      id: id,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
    };
  }
}
