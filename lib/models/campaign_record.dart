import 'package:cloud_firestore/cloud_firestore.dart';

class CampaignRecord {
  CampaignRecord({
    required this.id,
    required this.campaignName,
    required this.channel,
    required this.reach,
    required this.engagement,
    required this.leadsGenerated,
    required this.date,
    required this.owner,
    required this.createdAt,
  });

  final String id;
  final String campaignName;
  final String channel;
  final int reach;
  final int engagement;
  final int leadsGenerated;
  final DateTime? date;
  final String owner;
  final DateTime? createdAt;

  factory CampaignRecord.fromFirestore(Map<String, dynamic> data, String id) {
    return CampaignRecord(
      id: id,
      campaignName: data['campaignName'] ?? '',
      channel: data['channel'] ?? '',
      reach: (data['reach'] as num? ?? 0).toInt(),
      engagement: (data['engagement'] as num? ?? 0).toInt(),
      leadsGenerated: (data['leadsGenerated'] as num? ?? 0).toInt(),
      date: (data['date'] as Timestamp?)?.toDate(),
      owner: data['owner'] ?? 'Unassigned',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'campaignName': campaignName,
      'channel': channel,
      'reach': reach,
      'engagement': engagement,
      'leadsGenerated': leadsGenerated,
      'date': date == null ? null : Timestamp.fromDate(date!),
      'owner': owner,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    };
  }
}
