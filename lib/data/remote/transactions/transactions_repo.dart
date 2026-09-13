import 'package:creatify_mobile/data/models/requests/change_wallet_pin_req.dart';
import 'package:creatify_mobile/data/models/requests/create_wallet_pin_req.dart';
import 'package:creatify_mobile/data/models/requests/withdraw_req.dart';
import 'package:creatify_mobile/data/models/responses/fund_wallet_dto.dart';
import 'package:creatify_mobile/data/models/responses/make_payment_dto.dart';
import 'package:creatify_mobile/data/models/responses/transaction_dto.dart';
import 'package:creatify_mobile/data/models/responses/wallet_dto.dart';
import 'package:creatify_mobile/data/remote/transactions/transactions_service.dart';

abstract class TransactionsRepo {
  Future<MakePaymentDto> initializePayment(String bookingId, String paymentMethod);
  Future<String> verifyPayment(String reference);
  Future<TransactionDto> getTransactions(
      {String? category,
      String? status,
      String? minAmount,
      String? maxAmount,
      String? startDate,
      String? endDate});
  Future<TransactionItemDto> getTransactionDetails(String transactionId);
  Future<WalletDto> getwalletDetails();
  Future<String> createWalletPin(CreateWalletPinReq req);
  Future<String> changeWalletPin(ChangeWalletPinReq req);
  Future<String> withdrawFromWallet(WithdrawReq req);
  Future<FundWalletDto> fundWalletWithCard(num amount);
  Future<String> verifyWalletFunding(String reference);
  Future<String> forgotPin(String email);
  Future<String> resendForgotPin(String email);
  Future<String> verifyPin(String email, String code);
  Future<String> resetPin(String email, String code, String newPin);
}

class TransactionsRepoImpl implements TransactionsRepo {
  final TransactionsService _transactionsService;

  TransactionsRepoImpl(this._transactionsService);

  @override
  Future<TransactionItemDto> getTransactionDetails(String transactionId) async {
    return await _transactionsService.getTransactionDetails(transactionId);
  }

  @override
  Future<TransactionDto> getTransactions({
    String? category,
    String? status,
    String? minAmount,
    String? maxAmount,
    String? startDate,
    String? endDate,
  }) async {
    return await _transactionsService.getTransactions(
      category: category,
      status: status,
      minAmount: minAmount,
      maxAmount: maxAmount,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<MakePaymentDto> initializePayment(String bookingId, String paymentMethod) async {
    return await _transactionsService.initializePayment(bookingId, paymentMethod);
  }

  @override
  Future<String> verifyPayment(String reference) async {
    return await _transactionsService.verifyPayment(reference);
  }

  @override
  Future<String> changeWalletPin(ChangeWalletPinReq req) async {
    return await _transactionsService.changeWalletPin(req);
  }

  @override
  Future<String> createWalletPin(CreateWalletPinReq req) async {
    return await _transactionsService.createWalletPin(req);
  }

  @override
  Future<FundWalletDto> fundWalletWithCard(num amount) async {
    return await _transactionsService.fundWalletWithCard(amount);
  }

  @override
  Future<WalletDto> getwalletDetails() async {
    return await _transactionsService.getwalletDetails();
  }

  @override
  Future<String> verifyWalletFunding(String reference) async {
    return await _transactionsService.verifyWalletFunding(reference);
  }

  @override
  Future<String> withdrawFromWallet(WithdrawReq req) async {
    return await _transactionsService.withdrawFromWallet(req);
  }

  @override
  Future<String> forgotPin(String email) async {
    return await _transactionsService.forgotPin(email);
  }

  @override
  Future<String> resetPin(String email, String code, String newPin) async {
    return await _transactionsService.resetPin(email, code, newPin);
  }

  @override
  Future<String> verifyPin(String email, String code) async {
    return await _transactionsService.verifyPin(email, code);
  }

  @override
  Future<String> resendForgotPin(String email) async {
    return await _transactionsService.resendForgotPin(email);
  }
}
