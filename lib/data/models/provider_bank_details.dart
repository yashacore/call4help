class ProviderBankDetails {
  final int id;
  final int providerId;
  final String accountHolderName;
  final String accountNumber;
  final String ifsc;
  final String bankName;
  final bool isVerified;
  final DateTime createdAt;

  ProviderBankDetails({
    required this.id,
    required this.providerId,
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifsc,
    required this.bankName,
    required this.isVerified,
    required this.createdAt,
  });

  factory ProviderBankDetails.fromJson(Map<String, dynamic> json) {
    return ProviderBankDetails(
      id: json['id'],
      providerId: json['provider_id'],
      accountHolderName: json['account_holder_name'],
      accountNumber: json['account_number'],
      ifsc: json['ifsc'],
      bankName: json['bank_name'],
      isVerified: json['is_verified'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
