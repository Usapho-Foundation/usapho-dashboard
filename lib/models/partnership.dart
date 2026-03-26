import 'package:cloud_firestore/cloud_firestore.dart';

class Partnership {
  Partnership({
    required this.id,
    required this.partnerName,
    required this.type,
    required this.status,
    required this.engagementLevel,
    required this.lastInteractionDate,
    required this.activityCount,
    required this.owner,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String partnerName;
  final String type;
  final String status;
  final String engagementLevel;
  final DateTime? lastInteractionDate;
  final int activityCount;
  final String owner;
  final String notes;
  final DateTime? createdAt;

  factory Partnership.fromFirestore(Map<String, dynamic> data, String id) {
    return Partnership(
      id: id,
      partnerName: data['partnerName'] ?? '',
      type: data['type'] ?? 'corporate',
      status: data['status'] ?? 'prospect',
      engagementLevel: data['engagementLevel'] ?? 'medium',
      lastInteractionDate: (data['lastInteractionDate'] as Timestamp?)
          ?.toDate(),
      activityCount: (data['activityCount'] as num? ?? 0).toInt(),
      owner: data['owner'] ?? 'Unassigned',
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'partnerName': partnerName,
      'type': type,
      'status': status,
      'engagementLevel': engagementLevel,
      'lastInteractionDate': lastInteractionDate == null
          ? null
          : Timestamp.fromDate(lastInteractionDate!),
      'activityCount': activityCount,
      'owner': owner,
      'notes': notes,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    };
  }
}
