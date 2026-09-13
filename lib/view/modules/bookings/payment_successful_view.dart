import 'package:creatify_mobile/data/models/responses/conversation_dto.dart';
import 'package:creatify_mobile/view/modules/chats/chat_conversation_view.dart';
import 'package:creatify_mobile/view/modules/chats/vm/chat_vm.dart';
import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PaymentSuccessfulView extends ConsumerStatefulWidget {
  final String? creatorName, creatorId, bookingId;
  const PaymentSuccessfulView({
    super.key,
    this.creatorName,
    this.creatorId,
    this.bookingId,
  });

  @override
  ConsumerState<PaymentSuccessfulView> createState() => _PaymentSuccessfulViewState();
}

class _PaymentSuccessfulViewState extends ConsumerState<PaymentSuccessfulView> {
  @override
  Widget build(BuildContext context) {
    final createChatLoading = ref.watch(createChatNotifier).isLoading;

    ref.listen(createChatNotifier, (_, value) {
      if (value is AsyncData<ConversationDto>) {
        ref.read(navBarController.notifier).index = 3;
        context.popToFirst();
        context.push(
          ChatConversationView(conversation: value.value),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: createChatLoading,
      child: PopScope(
        canPop: false,
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(AppImages.transactionsIllustration),
              24.0.height,
              Text(
                'Payment Successful!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.subHeading,
                    ),
              ),
              12.0.height,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "We've sent your booking request to ${widget.creatorName}. You will be notified once they respond.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.body,
                      ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MainButton(
                  text: 'Continue',
                  onPressed: () {
                    context.popToFirst();

                    ref.read(navBarController.notifier).index = 2;
                  },
                ),
                12.0.height,
                TextButton(
                  onPressed: () {
                    ref
                        .read(createChatNotifier.notifier)
                        .createNewChat(widget.creatorId!, widget.bookingId!);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppImages.message,
                        colorFilter: AppColors.primary.colorFilterMode(),
                      ),
                      3.0.width,
                      Text(
                        'Chat with ${widget.creatorName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (createChatLoading) ...[
                        10.0.width,
                        LoadingAnimationWidget.hexagonDots(
                          color: AppColors.primary,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                ),
                80.0.height,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
