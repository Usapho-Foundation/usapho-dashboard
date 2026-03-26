import 'package:cloud_firestore/cloud_firestore.dart';

class ProgramRecord {
  ProgramRecord({
    required this.id,
    required this.programName,
    required this.startDate,
    required this.endDate,
    required this.participants,
    required this.completionRate,
    required this.impactScore,
    required this.fundingSource,
    required this.programLead,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String programName;
  final DateTime? startDate;
  final DateTime? endDate;
  final int participants;
  final double completionRate;
  final double impactScore;
  final String fundingSource;
  final String programLead;
  final String status;
  final DateTime? createdAt;

  factory ProgramRecord.fromFirestore(Map<String, dynamic> data, String id) {
    return ProgramRecord(
      id: id,
      programName: data['programName'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      participants: (data['participants'] as num? ?? 0).toInt(),
      completionRate: (data['completionRate'] ?? 0).toDouble(),
      impactScore: (data['impactScore'] ?? 0).toDouble(),
      fundingSource: data['fundingSource'] ?? '',
      programLead: data['programLead'] ?? 'Unassigned',
      status: data['status'] ?? 'planned',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'programName': programName,
      'startDate': startDate == null ? null : Timestamp.fromDate(startDate!),
      'endDate': endDate == null ? null : Timestamp.fromDate(endDate!),
      'participants': participants,
      'completionRate': completionRate,
      'impactScore': impactScore,
      'fundingSource': fundingSource,
      'programLead': programLead,
      'status': status,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    };
  }
}
