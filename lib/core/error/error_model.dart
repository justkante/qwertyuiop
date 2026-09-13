import 'dart:convert';

FailureRes failureResFromJson(String str) =>
    FailureRes.fromJson(json.decode(str));

class FailureRes {
  String message;
  String err;
  Error error;

  FailureRes({required this.message, required this.error, required this.err});

  factory FailureRes.fromJson(Map<String, dynamic> json) => FailureRes(
        message: json["message"]?.toString() ?? "",
        err: json["error"]?.toString() ?? "",
        error: Error.fromJson(json["errors"] ?? {}),
      );
}

class Error {
  String? message;
  String? phoneNumber;
  String? email;
  String? firstName;
  String? lastName;
  String? username;
  String? referralCode;
  String? amount;
  String? code;
  String? pin;
  String? transactionPin;
  String? password;
  String? recipient;
  String? token;

  Error(
      {required this.message,
      this.phoneNumber,
      this.email,
      this.username,
      this.firstName,
      this.amount,
      this.code,
      this.pin,
      this.recipient,
      this.transactionPin,
      this.password,
      this.referralCode,
      this.token,
      this.lastName});

  factory Error.fromJson(Map<String, dynamic>? json) => Error(
      message: json?["message"]?.toString() ?? "",
      phoneNumber: json?["phone_number"]?.toString() ?? "",
      email: json?["email"]?.toString() ?? "",
      firstName: json?["first_name"]?.toString() ?? "",
      amount: json?["amount"]?.toString() ?? "",
      pin: json?["pin"]?.toString() ?? "",
      code: json?["code"]?.toString() ?? "",
      lastName: json?["last_name"]?.toString() ?? "",
      referralCode: json?["referral_code"]?.toString() ?? "",
      transactionPin: json?["transaction_pin"]?.toString() ?? "",
      password: json?["password"]?.toString() ?? "",
      token: json?["token"]?.toString() ?? "",
      recipient: json?["recipient"]?.toString() ?? "",
      username: json?["username"]?.toString() ?? "");
  @override
  String toString() =>
      "message: $message";
}
