import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialRecord {
  FinancialRecord({
    required this.id,
    required this.month,
    required this.cashIn,
    required this.cashOut,
    required this.balance,
    required this.committedFunding,
    required this.createdAt,
  });

  final String id;
  final DateTime? month;
  final double cashIn;
  final double cashOut;
  final double balance;
  final double committedFunding;
  final DateTime? createdAt;

  factory FinancialRecord.fromFirestore(Map<String, dynamic> data, String id) {
    return FinancialRecord(
      id: id,
      month: (data['month'] as Timestamp?)?.toDate(),
      cashIn: (data['cashIn'] ?? 0).toDouble(),
      cashOut: (data['cashOut'] ?? 0).toDouble(),
      balance: (data['balance'] ?? 0).toDouble(),
      committedFunding: (data['committedFunding'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'month': month == null ? null : Timestamp.fromDate(month!),
      'cashIn': cashIn,
      'cashOut': cashOut,
      'balance': balance,
      'committedFunding': committedFunding,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    };
  }
}
