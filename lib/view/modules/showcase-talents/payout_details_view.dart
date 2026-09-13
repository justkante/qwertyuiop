import 'package:creatify_mobile/data/models/requests/resolve_bank_acct_req.dart';
import 'package:creatify_mobile/data/models/requests/save_payout_details_req.dart';
import 'package:creatify_mobile/data/models/responses/bank_item_dto.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/bank_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/payout_details_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/resolve_bank_account_vm.dart';
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
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PayoutDetailsView extends ConsumerStatefulWidget {
  const PayoutDetailsView({super.key});

  @override
  ConsumerState<PayoutDetailsView> createState() => _PayoutDetailsViewState();
}

class _PayoutDetailsViewState extends ConsumerState<PayoutDetailsView> {
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

    ref.listen(savePayoutDetailsProvider, (_, value) {
      if (value is AsyncData<String>) {
        Navigator.of(context).pop(true);
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
      absorbing: savePayoutLoading,
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MARK: Title
              Row(
                children: [
                  Text(
                    'Payout Details',
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
              32.0.height,

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
                suffixIcon: const Icon(
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
                validator: validateGeneric,
              ),
              12.0.height,

              TextInputField(
                header: 'Account Name',
                controller: accountName,
                hint: 'Enter Account Name',
                readOnly: true,
                inputType: TextInputType.text,
                suffixIcon: resolvingBankAccount
                    ? CircularProgressIndicator.adaptive(
                        constraints: BoxConstraints.tight(const Size(16, 16)),
                        padding: const EdgeInsets.all(12.0),
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        strokeWidth: 2,
                      )
                    : null,
                validator: validateGeneric,
              ),
              32.0.height,
            ],
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            12.0.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ListenableBuilder(
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
            ),
            24.0.height,
          ],
        ),
      ),
    );
  }
}
