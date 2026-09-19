import 'package:creatify_mobile/core/error/api_exception.dart';
import 'package:creatify_mobile/core/error/stripe_onboarding_exception.dart';
import 'package:creatify_mobile/core/http/http_service.dart';
import 'package:creatify_mobile/core/utils/app_url.dart';
import 'package:creatify_mobile/data/models/responses/stripe_onboarding_data_dto.dart';
import 'package:creatify_mobile/data/models/requests/change_wallet_pin_req.dart';
import 'package:creatify_mobile/data/models/requests/create_wallet_pin_req.dart';
import 'package:creatify_mobile/data/models/requests/withdraw_req.dart';
import 'package:creatify_mobile/data/models/responses/fund_wallet_dto.dart';
import 'package:creatify_mobile/data/models/responses/make_payment_dto.dart';
import 'package:creatify_mobile/data/models/responses/transaction_dto.dart';
import 'package:creatify_mobile/data/models/responses/wallet_dto.dart';

class TransactionsService {
  final HttpService _networkService;

  TransactionsService({required HttpService networkService}) : _networkService = networkService;

  Future<MakePaymentDto> initializePayment(String bookingId, String paymentMethod) async {
    try {
      final response = await _networkService.request(
          endpoints.initializePayment(bookingId), RequestMethod.post,
          data: {"payment_method": paymentMethod});

      return MakePaymentDto.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> verifyPayment(String reference) async {
    try {
      final response = await _networkService.request(
        endpoints.verifyPayment(reference),
        RequestMethod.get,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<TransactionDto> getTransactions({
    String? category,
    String? status,
    String? minAmount,
    String? maxAmount,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final String queries = {
        if (category != null && category.isNotEmpty) 'category': category,
        if (status != null && status.isNotEmpty) 'status': status,
        if (minAmount != null && minAmount.isNotEmpty) 'min_amount': minAmount,
        if (maxAmount != null && maxAmount.isNotEmpty) 'max_amount': maxAmount,
        if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
        if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
      }
          .entries
          .map((e) => "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}")
          .join('&');

      final response = await _networkService.request(
        "${endpoints.getTransactions}?$queries",
        RequestMethod.get,
      );

      return TransactionDto.fromJson(response.data);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<TransactionItemDto> getTransactionDetails(String transactionId) async {
    try {
      final response = await _networkService.request(
        endpoints.getTransactionDetails(transactionId),
        RequestMethod.get,
      );

      return TransactionItemDto.fromJson(response.data['message']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<WalletDto> getwalletDetails() async {
    try {
      final response = await _networkService.request(
        endpoints.getOrCreateWallet,
        RequestMethod.get,
      );

      return WalletDto.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> createWalletPin(CreateWalletPinReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.createWalletPin,
        RequestMethod.post,
        data: req.toJson(),
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> changeWalletPin(ChangeWalletPinReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.changeWalletPin,
        RequestMethod.post,
        data: req.toJson(),
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> withdrawFromWallet(WithdrawReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.withdrawFromWallet,
        RequestMethod.post,
        data: req.toJson(),
      );

      return response.data['message'];
    } on ApiException catch (e) {
      final data = e.responseData?['data'];
      if (data != null && data['requires_stripe_onboarding'] == true) {
        throw StripeOnboardingException(
          message: e.message,
          onboardingData: StripeOnboardingData.fromJson(data),
        );
      }
      throw e.toString();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<FundWalletDto> fundWalletWithCard(num amount) async {
    try {
      final response = await _networkService.request(
        endpoints.fundWithCard,
        RequestMethod.post,
        data: {
          'amount': amount,
        },
      );

      final data = response.data['data'];
      if (data == null) {
        throw 'Failed to initialize payment: No data received from server';
      }
      return FundWalletDto.fromJson(data);
    } catch (e) {
      if (e is ApiException) {
         throw e.message;
      }
      throw e.toString();
    }
  }

  Future<String> verifyWalletFunding(String reference) async {
    try {
      final response = await _networkService.request(
        endpoints.verifyWalletFunding(reference),
        RequestMethod.get,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> forgotPin(String email) async {
    try {
      final response = await _networkService.request(
        endpoints.forgotPin,
        RequestMethod.post,
        data: {
          'email': email,
        },
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> resendForgotPin(String email) async {
    try {
      final response = await _networkService.request(
        endpoints.resendVerifyWalletPin,
        RequestMethod.post,
        data: {
          'email': email,
        },
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> verifyPin(String email, String code) async {
    try {
      final response = await _networkService.request(
        endpoints.verifyPin,
        RequestMethod.post,
        data: {
          'email': email,
          'otp_code': code,
        },
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> resetPin(String email, String code, String newPin) async {
    try {
      final response = await _networkService.request(
        endpoints.resetPin,
        RequestMethod.post,
        data: {
          'email': email,
          'otp_code': code,
          'new_pin': newPin,
        },
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }
}
