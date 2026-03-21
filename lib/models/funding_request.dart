class FundingRequest {
  final String id;
  final String companyName;
  final double amount;
  final String status;

  FundingRequest({
    required this.id,
    required this.companyName,
    required this.amount,
    required this.status,
  });

  factory FundingRequest.fromFirestore(Map<String, dynamic> data, String id) {
    return FundingRequest(
      id: id,
      companyName: data['companyName'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'amount': amount,
      'status': status,
    };
  }

  FundingRequest copyWith({
    String? id,
    String? companyName,
    double? amount,
    String? status,
  }) {
    return FundingRequest(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      amount: amount ?? this.amount,
      status: status ?? this.status,
    );
  }
}
