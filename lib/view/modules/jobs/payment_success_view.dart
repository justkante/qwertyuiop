import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/view/modules/chats/chat_conversation_view.dart';
import 'package:creatify_mobile/view/modules/chats/vm/chat_vm.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';

class PaymentSuccessView extends ConsumerWidget {
  final String creatorName;
  final String creatorId;
  const PaymentSuccessView({super.key, required this.creatorName, required this.creatorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ),
              const Spacer(),
              Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1EF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    AppImages.transactionSuccessful,
                    height: 120,
                  ),
                ),
              ),
              40.0.height,
              const Text(
                'Payment Successful!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.heading),
              ),
              16.0.height,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'We\'ve sent your booking request to $creatorName. You\'ll be notified once they respond',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.body.withOpacity(0.6),
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // Logic to start chat
                      final result = await ref.read(chatRepository).createChat(creatorId, '');
                      if (context.mounted) {
                        context.pushReplacement(ChatConversationView(conversation: result));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ToastDialog.showError('Failed to start chat: $e', context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 18),
                      8.0.width,
                      Text(
                        'Chat with "$creatorName"',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              20.0.height,
            ],
          ),
        ),
      ),
    );
  }
}
