class ProviderBankModel {
  final String accountHolderName;
  final String accountNumber;
  final String ifsc;
  final String bankName;

  ProviderBankModel({
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifsc,
    required this.bankName,
  });

  Map<String, dynamic> toJson() {
    return {
      "account_holder_name": accountHolderName,
      "account_number": accountNumber,
      "ifsc": ifsc,
      "bank_name": bankName,
    };
  }
}
