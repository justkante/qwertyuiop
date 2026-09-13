// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:creatify_mobile/core/utils/constants.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/verify_payment_vm.dart';
import 'package:creatify_mobile/view/modules/jobs/vm/job_controller.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/make_subscription_payment_vm.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/wallet_funding_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';

import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatefulHookConsumerWidget {
  final String url;
  final String routeName;
  final String? paymentReference, bookingId, jobApplicationId;
  const WebviewScreen({
    super.key,
    required this.url,
    required this.routeName,
    this.paymentReference,
    this.bookingId,
    this.jobApplicationId,
  });
  static String path = "/webview/:url/:routeName";

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends ConsumerState<WebviewScreen> with RestorationMixin {
  @override
  String get restorationId => 'webview_screen';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {}

  String name = "";
  int pageProgress = 0;
  bool pageLoading = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) '
        'Version/17.0 Mobile/15E148 Safari/604.1',
      )
      ..setOnConsoleMessage((message) {
        log(message.toString());
      })
      ..enableZoom(true)
      ..loadRequest(Uri.parse(widget.url))
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                pageProgress = progress;
                pageLoading = progress < 100;
              });
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                pageLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest navRequest) async {
            // Pay For Booking
            if (widget.routeName == 'Make Payment' &&
                navRequest.url.contains(widget.paymentReference ?? '')) {
              ref
                  .read(verifyPaymentProvider.notifier)
                  .verify(widget.paymentReference ?? '', widget.bookingId ?? '');
              context.pop(true);
            }

            // Subscription Payment
            else if (widget.routeName == 'Subscription Payment' &&
                navRequest.url.contains(widget.paymentReference ?? '') &&
                navRequest.url.contains(Constants.url)) {
              ref
                  .read(verifySubscriptionPaymentProvider.notifier)
                  .verifySubscriptionPayment(widget.paymentReference ?? '');
              context.pop(true);
            }

            // Fund Wallet Payment
            else if (widget.routeName == 'Fund Wallet' &&
                navRequest.url.contains(widget.paymentReference ?? '')) {
              ref
                  .read(verifyWalletFundingProvider.notifier)
                  .verifyFundingPayment(widget.paymentReference ?? '');
              context.pop(true);
            }

            // Job Application Payment
            else if (widget.routeName == 'Job Payment' &&
                navRequest.url.contains(widget.paymentReference ?? '')) {
              ref.read(jobControllerProvider.notifier).respondToApplication(
                    widget.jobApplicationId ?? '',
                    'accepted',
                    paymentReference: widget.paymentReference,
                  );
              context.pop(true);
            }

            // Creator Onboarding
            else if (widget.routeName.contains('Onboarding') &&
                navRequest.url.contains(Constants.url)) {
              ref.invalidate(getOnboardingStatusProvider);
              context.pop(true);
            }

            return NavigationDecision.navigate;
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            widget.routeName,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.subHeading,
            ),
          ),
        ),
        body: pageLoading
            ? Center(
                child: Column(
                  spacing: 12,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SpinKitRing(
                      color: AppColors.primary,
                      size: 100,
                      lineWidth: 3,
                    ),
                    Text(
                      "$pageProgress%",
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    )
                  ],
                ),
              )
            : WebViewWidget(controller: _controller),
      ),
    );
  }
}
