import 'dart:developer';
import 'package:creatify_mobile/data/models/responses/fund_wallet_dto.dart';
import 'package:creatify_mobile/data/models/responses/job_application_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/stripe_init.dart';
import 'package:creatify_mobile/view/modules/webview/app_webview.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../vm/job_controller.dart';
import '../payment_success_view.dart';

class JobPaymentConfirmationSheet extends ConsumerWidget {
  final JobApplicationDto application;
  const JobPaymentConfirmationSheet({super.key, required this.application});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initializing = ref.watch(initializeJobPaymentProvider).isLoading;
    final userData = ref.watch(userControllerProvider);
    final jobPrice = application.job?.price ?? 0;
    final currency = application.job?.currency ?? userData.primaryCurrency ?? 'NGN';

    ref.listen(initializeJobPaymentProvider, (_, next) async {
      if (next is AsyncData<FundWalletDto>) {
        if (userData.countryCode == 'NG') {
          context.pop(); // Pop sheet
          NavigationService.instance.push(
            WebviewScreen(
              url: next.value.authorizationUrl ?? '',
              routeName: 'Job Payment',
              paymentReference: next.value.reference ?? '',
              jobApplicationId: application.id,
            ),
          ).then((value) {
            if (value == true && context.mounted) {
              NavigationService.instance.pushReplacement(PaymentSuccessView(
                creatorName: application.user?.name ?? 'Creator',
                creatorId: application.userId ?? '',
              ));
            }
          });
        } else {
          // Stripe flow
          await initStripePayment(
            paymentIntent: next.value.stripePaymentIntentId ?? '',
            clientSecret: next.value.clientSecret ?? '',
            context: context,
          ).then((value) async {
            try {
              await Stripe.instance.presentPaymentSheet();
              log('Stripe payment successful for job: ${application.jobId}');

              // Call respond to application with the reference
              final success = await ref.read(jobControllerProvider.notifier).respondToApplication(
                application.id!,
                'accepted',
                paymentReference: next.value.reference,
              );

              if (success && context.mounted) {
                context.pop(); // Pop sheet
                NavigationService.instance.pushReplacement(PaymentSuccessView(
                  creatorName: application.user?.name ?? 'Creator',
                  creatorId: application.userId ?? '',
                ));
              }
            } catch (e) {
              log('Stripe payment failed/cancelled: $e');
            }
          });
        }
      }
      if (next is AsyncError) {
        ToastDialog.showError(next.error.toString(), context);
      }
    });

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          16.0.height,
          SvgPicture.asset(AppImages.handWallet, height: 80),
          24.0.height,
          Text(
            'Confirm Payment',
            style: context.textTheme.displayMedium?.copyWith(fontSize: 20),
          ),
          12.0.height,
          Text(
            'To accept this application, you need to pay the job amount. The funds will be held securely until the job is completed.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(color: AppColors.body),
          ),
          32.0.height,
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Amount to Pay',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  jobPrice.amountWithCurrency(currency),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          40.0.height,
          MainButton(
            text: 'Pay & Accept Application',
            isLoading: initializing,
            onPressed: () {
              ref.read(initializeJobPaymentProvider.notifier).initializePayment(application.id!);
            },
          ),
          16.0.height,
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.highlightRed),
            ),
          ),
          24.0.height,
        ],
      ),
    );
  }
}
