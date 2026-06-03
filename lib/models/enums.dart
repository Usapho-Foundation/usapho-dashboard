// Enums for strongly-typed funding opportunity classification and tracking.

/// Represents the type/category of a funding opportunity.
enum FundingType {
  /// Funding restricted for specific use by the funder
  restricted('restricted'),
  /// Funding with no restrictions on use
  unrestricted('unrestricted'),
  /// Formal proposal submission
  proposal('proposal'),
  /// Revenue activity or income-generating activity
  incomeActivity('income_activity'),
  /// Forecasted future income
  forecast('forecast');

  const FundingType(this.value);
  final String value;

  /// Parse string value to FundingType enum
  static FundingType fromString(String value) {
    return FundingType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FundingType.restricted,
    );
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case FundingType.restricted:
        return 'Restricted Funding';
      case FundingType.unrestricted:
        return 'Unrestricted Funding';
      case FundingType.proposal:
        return 'Proposal';
      case FundingType.incomeActivity:
        return 'Income Activity';
      case FundingType.forecast:
        return 'Forecast';
    }
  }
}

/// Represents the source/category of funding (e.g., corporate, foundation).
enum SourceCategory {
  corporate('corporate'),
  foundation('foundation'),
  individual('individual'),
  partnership('partnership');

  const SourceCategory(this.value);
  final String value;

  /// Parse string value to SourceCategory enum
  static SourceCategory fromString(String value) {
    return SourceCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SourceCategory.corporate,
    );
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case SourceCategory.corporate:
        return 'Corporates';
      case SourceCategory.foundation:
        return 'Donor Foundation Funding';
      case SourceCategory.individual:
        return 'Individual Donors';
      case SourceCategory.partnership:
        return 'Partnerships / Joint Ventures / Special Programmes';
    }
  }
}

/// Represents the legacy workflow status of a funding opportunity.
/// This tracks the pipeline state (pre-approval) and funding receipt status.
enum FundingStatus {
  pipeline('pipeline'),
  submitted('submitted'),
  approved('approved'),
  received('received'),
  declined('declined');

  const FundingStatus(this.value);
  final String value;

  /// Parse string value to FundingStatus enum
  static FundingStatus fromString(String value) {
    return FundingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FundingStatus.pipeline,
    );
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case FundingStatus.pipeline:
        return 'Pipeline';
      case FundingStatus.submitted:
        return 'Submitted';
      case FundingStatus.approved:
        return 'Approved';
      case FundingStatus.received:
        return 'Received';
      case FundingStatus.declined:
        return 'Declined';
    }
  }
}

/// Represents the proposal lifecycle status (separate from legacy funding status).
/// Only applicable to funding opportunities of type [FundingType.proposal].
enum ProposalStatus {
  pending('pending'),
  inProgress('in_progress'),
  successful('successful'),
  noResponse('no_response'),
  noDeal('no_deal');

  const ProposalStatus(this.value);
  final String value;

  /// Parse string value to ProposalStatus enum
  static ProposalStatus fromString(String value) {
    return ProposalStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProposalStatus.pending,
    );
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case ProposalStatus.pending:
        return 'Pending';
      case ProposalStatus.inProgress:
        return 'In Progress';
      case ProposalStatus.successful:
        return 'Successful';
      case ProposalStatus.noResponse:
        return 'No Response';
      case ProposalStatus.noDeal:
        return 'No Deal';
    }
  }
}
