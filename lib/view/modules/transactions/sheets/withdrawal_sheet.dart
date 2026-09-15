import 'package:creatify_mobile/data/models/requests/resolve_bank_acct_req.dart';
import 'package:creatify_mobile/data/models/responses/bank_item_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/bank_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/resolve_bank_account_vm.dart';
import 'package:creatify_mobile/view/modules/transactions/confirm_withdrawal_view.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/transactions_providers.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/thousands_formatter.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class WithdrawalSheet extends ConsumerStatefulWidget {
  const WithdrawalSheet({super.key});

  @override
  ConsumerState<WithdrawalSheet> createState() => _WithdrawalSheetState();
}

class _WithdrawalSheetState extends ConsumerState<WithdrawalSheet> {
  final bankName = TextEditingController();
  final accountNumber = TextEditingController();
  final accountName = TextEditingController();
  final amount = TextEditingController();

  BankItemDto? selectedBank;

  resolveAccountNumber() {
    ref.read(resolveBankAccountProvider.notifier).resolveBankAccount(
          ResolveBankAccountReq(
            accountNumber: accountNumber.text,
            bankCode: selectedBank?.code ?? '',
          ),
        );
  }

  @override
  void initState() {
    super.initState();

    // Initialize with existing data if available
    ref.read(fetchPayoutDetailsProvider.future).then((payoutDetails) {
      bankName.text = payoutDetails.bankName ?? '';
      accountNumber.text = payoutDetails.accountNumber ?? '';
      accountName.text = payoutDetails.accountName ?? '';

      setState(() {
        // Add The Existing Bank
        selectedBank = BankItemDto(
          name: payoutDetails.bankName,
          code: payoutDetails.bankCode,
          slug: null,
        );
      });
    });
  }

  @override
  void dispose() {
    bankName.dispose();
    accountNumber.dispose();
    accountName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final resolvingBankAccount = ref.watch(resolveBankAccountProvider).isLoading;
    final fetchingPayoutDetails = ref.watch(fetchPayoutDetailsProvider).isLoading;
    final walletBalance = ref.watch(walletBalanceProvider.notifier).state;

    ref.listen(resolveBankAccountProvider, (_, value) {
      if (value is AsyncData) {
        setState(() {
          accountName.text = value.value?.accountName ?? '';
        });
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
        setState(() {
          accountName.clear();
        });
      }
    });

    return AbsorbPointer(
      absorbing: (resolvingBankAccount || fetchingPayoutDetails),
      child: SafeArea(
        top: true,
        left: false,
        right: false,
        bottom: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              12.0.height,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MARK: Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Withdraw Funds',
                            style: context.textTheme.headlineSmall?.copyWith(fontSize: 23),
                          ),
                          6.0.width,
                          SvgPicture.asset(
                            AppImages.bank,
                            width: 24,
                            height: 24,
                          )
                        ],
                      ),
                      6.0.height,
                      Text(
                        "Provide your bank details to withdraw your earnings securely.",
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall,
                      ),
                      24.0.height,

                      // MARK: Form
                      TextInputField(
                        header: 'Amount',
                        controller: amount,
                        hint: 'Enter Amount',
                        inputType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                          LengthLimitingTextInputFormatter(17),
                          ThousandsFormatter(
                            allowFraction: true,
                            formatter: NumberFormat.decimalPattern(),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          } else if ((double.tryParse(value.removeCommas()) ?? 0) <
                              (userData.primaryCurrency == 'NGN' ? 500 : 1)) {
                            return 'Amount must be greater than ${userData.primaryCurrency == 'NGN' ? 500 : 1}';
                          }
                          return null;
                        },
                      ),
                      12.0.height,
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.highlightBlue50,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: AppColors.highlightBlue.withOpacity(0.2)),
                        ),
                        child: Row(
                          // crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SvgPicture.asset(
                              width: 16,
                              height: 16,
                              AppImages.wallet,
                              colorFilter: AppColors.highlightBlue.colorFilterMode(),
                            ),
                            8.0.width,
                            Text(
                              'Available Balance: ',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppColors.highlightBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              ref.watch(balanceVisibleController)
                                  ? walletBalance.amountWithCurrency(userData.primaryCurrency ?? '')
                                  : '●●●●●●●',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppColors.subHeading,
                                fontWeight: FontWeight.w500,
                                fontFamily: FontFamily.inter,
                              ),
                            )
                          ],
                        ),
                      ),

                      if (userData.primaryCurrency == 'NGN') ...[
                        16.0.height,
                        TextInputField(
                          header: 'Bank Name',
                          controller: bankName,
                          hint: 'Select Bank',
                          inputType: TextInputType.text,
                          onPressed: () async {
                            selectedBank = await AppBottomSheet.showBottomSheet(
                              context,
                              widget: const BankSheet(),
                            );

                            if (selectedBank != null) {
                              bankName.text = selectedBank?.name ?? '';
                              if (accountNumber.text.length == 10) {
                                resolveAccountNumber();
                              }
                            }
                          },
                          readOnly: true,
                          suffixIcon: (fetchingPayoutDetails)
                              ? CircularProgressIndicator.adaptive(
                                  constraints: BoxConstraints.tight(const Size(16, 16)),
                                  padding: const EdgeInsets.all(12.0),
                                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                  strokeWidth: 2,
                                )
                              : const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColors.body,
                                  size: 18,
                                ),
                          validator: validateGeneric,
                        ),
                        16.0.height,
                        TextInputField(
                          header: 'Account Number',
                          controller: accountNumber,
                          hint: 'Enter Account Number',
                          inputType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          onChanged: (value) {
                            if (value.length == 10 && selectedBank != null) {
                              resolveAccountNumber();
                            }
                          },
                          suffixIcon: (resolvingBankAccount || fetchingPayoutDetails)
                              ? CircularProgressIndicator.adaptive(
                                  constraints: BoxConstraints.tight(const Size(16, 16)),
                                  padding: const EdgeInsets.all(12.0),
                                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                  strokeWidth: 2,
                                )
                              : null,
                          validator: validateGeneric,
                        ),
                        12.0.height,
                        if (accountName.text.isNotEmpty) ...[
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppImages.blueTick,
                                colorFilter: AppColors.highlightGreen.colorFilterMode(),
                              ),
                              8.0.width,
                              Text(
                                accountName.text,
                                style: context.textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.highlightGreen),
                              ),
                              const Spacer(),
                              if ((resolvingBankAccount || fetchingPayoutDetails)) ...[
                                CircularProgressIndicator.adaptive(
                                  constraints: BoxConstraints.tight(const Size(16, 16)),
                                  padding: const EdgeInsets.all(12.0),
                                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                  strokeWidth: 2,
                                )
                              ],
                            ],
                          ),
                        ],
                        32.0.height,
                      ],
                    ],
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: Listenable.merge([
                  bankName,
                  accountNumber,
                  accountName,
                  amount,
                ]),
                builder: (context, child) {
                  final isValid = userData.primaryCurrency == 'NGN'
                      ? validateRequiredFields(
                            [
                              bankName.text,
                              accountNumber.text,
                              accountName.text,
                              amount.text,
                            ],
                          ) &&
                          ((double.tryParse(amount.text.replaceAll(',', '')) ?? 0) >= 500) &&
                          ((double.tryParse(amount.text.replaceAll(',', '')) ?? 0) <= walletBalance)
                      : validateRequiredFields(
                            [amount.text],
                          ) &&
                          ((double.tryParse(amount.text.replaceAll(',', '')) ?? 0) >= 1) &&
                          ((double.tryParse(amount.text.replaceAll(',', '')) ?? 0) <=
                              walletBalance);

                  return MainButton(
                    text: 'Withdraw Funds',
                    isLoading: false,
                    onPressed: isValid
                        ? () {
                            context.pop();

                            context.push(
                              ConfirmWithdrawalView(
                                amount: num.tryParse(amount.text.replaceAll(',', '')),
                                selectedBank: selectedBank,
                                accountNumber: accountNumber.text,
                                accountName: accountName.text,
                              ),
                            );
                          }
                        : null,
                  );
                },
              ),
              12.0.height,
            ],
          ),
        ),
      ),
    );
  }
}
