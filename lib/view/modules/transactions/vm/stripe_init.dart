import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> initStripePayment({
  required String paymentIntent,
  required String clientSecret,
  required BuildContext context,
}) async {
  try {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        customFlow: false,
        merchantDisplayName: 'Creatify',
        paymentIntentClientSecret: clientSecret,
        style: ThemeMode.system,
      ),
    );
  } catch (e) {
    if (context.mounted) {
      ToastDialog.showError(e.toString(), context);
    }
  }
}
