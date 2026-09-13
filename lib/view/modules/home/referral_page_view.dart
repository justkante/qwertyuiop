import 'package:creatify_mobile/core/utils/app_func_utils.dart';
import 'package:creatify_mobile/core/utils/constants.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/profile_id_widget.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/claim_referral_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/modules/home/widgets/referral_bar_indicator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ReferralPageView extends ConsumerStatefulWidget {
  const ReferralPageView({super.key});

  @override
  ConsumerState<ReferralPageView> createState() => _ReferralPageViewState();
}

class _ReferralPageViewState extends ConsumerState<ReferralPageView> {
  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final referralStates = ref.watch(fetchReferralStatsProvider);

    ref.listen(claimReferralRewardProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess('Referral Reward has been claimed', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Invite & Earn',
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.subHeading,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: referralStates.when(
          data: (data) => Column(
            children: [
              SvgPicture.asset(AppImages.gift),
              12.0.height,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Text(
                  userData.countryCode == 'NG'
                      ? 'Invite up to 5 friends and earn ${1500.amountWithCurrency('ngn')} for each successful referral.\n(Max reward: ${7500.amountWithCurrency('ngn')})'
                      : 'Invite up to 5 users and win a free subscription for up to 30 days',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontFamily: FontFamily.inter,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subHeading,
                  ),
                ),
              ),
              24.0.height,

              if ((data.pendingReferrals ?? 0) > 0) ...[
                // Info Card
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.highlightYellow50,
                    border: Border.all(color: AppColors.highlightYellow),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "You have ${data.pendingReferrals} pending referral(s) awaiting KYC verification. Once your referrals complete their KYC, you'll be able to claim your rewards.",
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.black2,
                      height: 1.5,
                    ),
                  ),
                ),
                16.0.height,
              ],

              if (userData.countryCode == 'NG') ...[
                // MARK: Referral Balance
                Row(
                  children: [
                    Text(
                      'Referral Balance:',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.body,
                      ),
                    ),
                    4.0.width,
                    Text(
                      data.totalEarned.amountWithCurrency('ngn'),
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black2,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: data.canClaim == true
                          ? () {
                              ref.read(claimReferralRewardProvider.notifier).claimReferralReward();
                            }
                          : null,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: data.canClaim == true
                                  ? AppColors.highlightCoral
                                  : AppColors.grey200,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Text(
                              'Claim',
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: data.canClaim == true ? AppColors.white : AppColors.grey400,
                              ),
                            ),
                          ),
                          if (ref.watch(claimReferralRewardProvider).isLoading) ...[
                            8.0.width,
                            LoadingAnimationWidget.hexagonDots(color: AppColors.black2, size: 14),
                          ],
                        ],
                      ),
                    )
                  ],
                ),
                16.0.height,
              ],

              // MARK: Referral Bar Indicator
              ReferralBarIndicator(
                currentAmount: data.totalEarned ?? 0,
                individualAmount: 1500,
              ),
              32.0.height,

              // Link and Copy Button
              ProfileIdWidget(
                profileId: data.referralCode ?? 'N/A',
              ),
              12.0.height,

              // Share Button
              MainButton(
                text: 'Invite',
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: () async {
                  await AppUtils.shareLink(
                      '${Constants.url}/profile/${data.referralCode ?? 'N/A'}', context);
                },
              ),
              24.0.height,

              // MARK: How it Works
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.grey150,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'How it Works',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.subHeading,
                      ),
                    ),
                    18.0.height,
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          const InstructionWidget(
                            instructionText: 'Share your code',
                            instructionSubText:
                                'Tap Invite or Copy and send your referral code to friends who want to join Creatify as creators',
                            image: AppImages.shareFilled,
                          ),
                          const InstructionWidget(
                            instructionText: 'They complete Creator onboarding',
                            instructionSubText:
                                'Your friend signs up, sets up a Creator profile and completes KYC\n(You can refer up to 5 friends)',
                            image: AppImages.taskFilled,
                          ),
                          InstructionWidget(
                            instructionText: userData.countryCode == 'NG'
                                ? 'Earn N1,500 each'
                                : 'Win a 30-day subscription',
                            instructionSubText: userData.countryCode == 'NG'
                                ? 'Get N1,500 for every creator fully onboarded and verified\nTap Claim to withdraw'
                                : "Get a 30-day subscription when you have up to 5 successful referrals",
                            image: AppImages.rewardFilled,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              24.0.height,
            ],
          ),
          loading: () => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                24.0.height,
                const Text('Loading Referral Stats...'),
                8.0.height,
                const CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ],
            ),
          ),
          error: (error, stackTrace) {
            return Center(
              child: Text(
                error.toString(),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.highlightRed,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class InstructionWidget extends StatelessWidget {
  final String instructionText, instructionSubText, image;
  const InstructionWidget({
    super.key,
    required this.instructionText,
    this.instructionSubText = '',
    this.image = AppImages.shareFilled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(image),
        8.0.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                instructionText,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.black2,
                ),
              ),
              4.0.height,
              Text(
                instructionSubText,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.body,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
