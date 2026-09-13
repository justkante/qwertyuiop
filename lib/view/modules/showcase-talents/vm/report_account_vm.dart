import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/data/models/requests/report_account_req.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReportCreatorAccountNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> reportCreatorAccount(ReportAccountReq req, {String? reportedReason}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(creatorRepository).reportCreatorAccount(req));

    if (!state.hasError) {
      mixpanel.trackEvent(
        'Reported Creator Account',
        properties: {
          'reported_user_id': req.reportedUserId,
          'reported_reason': reportedReason ?? 'Not Specified',
          'details': req.details,
        },
      );
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final reportCreatorAccountProvider =
    AutoDisposeAsyncNotifierProvider<ReportCreatorAccountNotifier, String>(
  ReportCreatorAccountNotifier.new,
);
