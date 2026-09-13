// To parse this JSON data, do
//
//     final resolvedBankAccountDto = resolvedBankAccountDtoFromJson(jsonString);

import 'dart:convert';

ResolvedBankAccountDto resolvedBankAccountDtoFromJson(String str) =>
    ResolvedBankAccountDto.fromJson(json.decode(str));

String resolvedBankAccountDtoToJson(ResolvedBankAccountDto data) => json.encode(data.toJson());

class ResolvedBankAccountDto {
  final String? accountNumber;
  final String? accountName;
  final int? bankId;

  ResolvedBankAccountDto({
    this.accountNumber,
    this.accountName,
    this.bankId,
  });

  ResolvedBankAccountDto copyWith({
    String? accountNumber,
    String? accountName,
    int? bankId,
  }) =>
      ResolvedBankAccountDto(
        accountNumber: accountNumber ?? this.accountNumber,
        accountName: accountName ?? this.accountName,
        bankId: bankId ?? this.bankId,
      );

  factory ResolvedBankAccountDto.fromJson(Map<String, dynamic> json) => ResolvedBankAccountDto(
        accountNumber: json["account_number"],
        accountName: json["account_name"],
        bankId: json["bank_id"],
      );

  Map<String, dynamic> toJson() => {
        "account_number": accountNumber,
        "account_name": accountName,
        "bank_id": bankId,
      };
}
