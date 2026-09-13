import 'package:creatify_mobile/core/services/receipt_export_service.dart';
import 'package:creatify_mobile/core/utils/app_func_utils.dart';
import 'package:creatify_mobile/data/models/responses/transaction_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/transactions/widgets/export_options_bottom_sheet.dart';
import 'package:creatify_mobile/view/modules/transactions/widgets/transaction_line.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TransactionDetailsView extends ConsumerStatefulWidget {
  final TransactionItemDto transactionDetails;
  const TransactionDetailsView({
    super.key,
    required this.transactionDetails,
  });

  @override
  ConsumerState<TransactionDetailsView> createState() => _TransactionDetailsViewState();
}

class _TransactionDetailsViewState extends ConsumerState<TransactionDetailsView> {
  // Create a GlobalKey to capture the widget
  final GlobalKey repaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Details',
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.subHeading,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            20.0.height,
            Center(
              child: Image.asset(
                AppImages.transactionSuccessful,
                width: 130,
                height: 130,
              ),
            ),
            24.0.height,
            for (var details in [
              ('Type', widget.transactionDetails.type?.replaceAll('_', ' ').toTitleCase() ?? ''),
              (
                'Cost',
                (widget.transactionDetails.amount ?? 0)
                    .amountWithCurrency(userData.primaryCurrency ?? '')
              ),
              if (widget.transactionDetails.fee != null)
                (
                  'Fee',
                  (widget.transactionDetails.fee ?? 0)
                      .amountWithCurrency(userData.primaryCurrency ?? '')
                ),
              if (widget.transactionDetails.gatewayFee != null)
                (
                  'Gateway Fee',
                  ((widget.transactionDetails.gatewayFee ?? 0)
                      .amountWithCurrency(userData.primaryCurrency ?? ''))
                ),
              if (widget.transactionDetails.platformFee != null)
                (
                  'Platform Fee',
                  ((widget.transactionDetails.platformFee ?? 0)
                      .amountWithCurrency(userData.primaryCurrency ?? ''))
                ),
              if (widget.transactionDetails.penaltyFee != null)
                (
                  'Penalty Fee',
                  ((widget.transactionDetails.penaltyFee ?? 0)
                      .amountWithCurrency(userData.primaryCurrency ?? ''))
                ),
              ('Transaction ID', widget.transactionDetails.paymentReference ?? ''),
              (
                'Date',
                widget.transactionDetails.paidAt == null
                    ? widget.transactionDetails.createdAt?.transactionDate() ?? ''
                    : widget.transactionDetails.paidAt!.transactionDate()
              ),
              ('Status', widget.transactionDetails.status?.toTitleCase() ?? ''),
            ])
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
                child: TransactionLine(
                  title: details.$1,
                  value: details.$2,
                  valueColor: details.$1 == 'Status'
                      ? switch (widget.transactionDetails.status) {
                          'pending' => AppColors.highlightYellow,
                          'failed' => AppColors.highlightRed,
                          'successful' => AppColors.highlightGreen,
                          _ => AppColors.subHeading,
                        }
                      : null,
                ),
              ),
            8.0.height,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TransactionLine(
                title: 'Final Payout',
                valueColor: AppColors.highlightGreen,
                value: (widget.transactionDetails.netAmount ?? 0)
                    .amountWithCurrency(userData.primaryCurrency ?? ''),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: MainButton(
                    color: AppColors.highlightRed,
                    text: 'Get Help',
                    onPressed: () {
                      AppUtils.openLink(SocialPlatform.email);
                    },
                  ),
                ),
                12.0.width,
                Expanded(
                  child: MainButton(
                    text: 'Download Receipt',
                    onPressed: () {
                      AppBottomSheet.showBottomSheet(
                        context,
                        widget: ExportOptionsBottomSheet(
                          onExportPdf: () {
                            ReceiptExportService.exportAsPdf(
                              widget.transactionDetails,
                              context,
                              ref,
                            );
                          },
                          onExportPng: () {
                            ReceiptExportService.exportAsPng(
                              context,
                              widget.transactionDetails,
                              ref,
                            );
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
            12.0.height,
          ],
        ),
      ),
    );
  }
}
