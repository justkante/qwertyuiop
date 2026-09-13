import 'package:creatify_mobile/data/models/requests/resolve_bank_acct_req.dart';
import 'package:creatify_mobile/data/models/requests/save_payout_details_req.dart';
import 'package:creatify_mobile/data/models/responses/bank_item_dto.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/bank_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/payout_details_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/resolve_bank_account_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PaymentAndPayoutSheet extends ConsumerStatefulWidget {
  const PaymentAndPayoutSheet({super.key});

  @override
  ConsumerState<PaymentAndPayoutSheet> createState() => _PaymentAndPayoutSheetState();
}

class _PaymentAndPayoutSheetState extends ConsumerState<PaymentAndPayoutSheet> {
  final bankName = TextEditingController();
  final accountNumber = TextEditingController();
  final accountName = TextEditingController();

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
    final savePayoutLoading = ref.watch(savePayoutDetailsProvider).isLoading;
    final resolvingBankAccount = ref.watch(resolveBankAccountProvider).isLoading;
    final fetchingPayoutDetails = ref.watch(fetchPayoutDetailsProvider).isLoading;

    ref.listen(savePayoutDetailsProvider, (_, value) {
      if (value is AsyncData<String>) {
        context.pop();
        ToastDialog.showSuccess('Payout Details Updated Successfully', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

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
      absorbing: (savePayoutLoading || resolvingBankAccount || fetchingPayoutDetails),
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
                      children: [
                        Text(
                          'Payment & Payout Details',
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
                      "Add or update your payout information. This ensures you get paid securely.",
                      style: context.textTheme.bodySmall,
                    ),
                    21.0.height,

                    // MARK: Form
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
                    12.0.height,

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
                      suffixIcon: (fetchingPayoutDetails)
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

                    TextInputField(
                      header: 'Account Name',
                      controller: accountName,
                      hint: 'Enter Account Name',
                      readOnly: true,
                      inputType: TextInputType.text,
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
                    24.0.height,
                  ],
                ),
              ),
            ),
            ListenableBuilder(
              listenable: Listenable.merge([
                bankName,
                accountNumber,
                accountName,
              ]),
              builder: (context, child) {
                final isValid = validateRequiredFields(
                  [
                    bankName.text,
                    accountNumber.text,
                    accountName.text,
                  ],
                );
                return MainButton(
                  text: 'Save & Continue',
                  isLoading: savePayoutLoading,
                  onPressed: isValid
                      ? () {
                          ref.read(savePayoutDetailsProvider.notifier).payoutOnboarding(
                                SavePayoutDetailsReq(
                                  bankCode: selectedBank?.code ?? '',
                                  bankName: bankName.text,
                                  accountNumber: accountNumber.text,
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
    );
  }
}
