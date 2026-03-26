enum DatePreset { allTime, currentQuarter, last6Months }

class DashboardFilter {
  const DashboardFilter({
    this.datePreset = DatePreset.allTime,
    this.owner,
    this.status,
    this.search = '',
  });

  final DatePreset datePreset;
  final String? owner;
  final String? status;
  final String search;

  DashboardFilter copyWith({
    DatePreset? datePreset,
    String? owner,
    bool clearOwner = false,
    String? status,
    bool clearStatus = false,
    String? search,
  }) {
    return DashboardFilter(
      datePreset: datePreset ?? this.datePreset,
      owner: clearOwner ? null : (owner ?? this.owner),
      status: clearStatus ? null : (status ?? this.status),
      search: search ?? this.search,
    );
  }
}
