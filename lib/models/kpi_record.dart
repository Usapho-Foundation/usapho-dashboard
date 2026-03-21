class KpiRecord {
  final String id;
  final String pillar;
  final String kpi;
  final double value;
  final double target;
  final String period;

  KpiRecord({
    required this.id,
    required this.pillar,
    required this.kpi,
    required this.value,
    required this.target,
    required this.period,
  });

  factory KpiRecord.fromFirestore(Map<String, dynamic> data, String id) {
    return KpiRecord(
      id: id,
      pillar: data['pillar'] ?? '',
      kpi: data['kpi'] ?? '',
      value: (data['value'] ?? 0).toDouble(),
      target: (data['target'] ?? 0).toDouble(),
      period: data['period'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pillar': pillar,
      'kpi': kpi,
      'value': value,
      'target': target,
      'period': period,
    };
  }

  double get achievement => target > 0 ? (value / target) * 100 : 0;

  bool get isOnTrack => achievement >= 100;
}
