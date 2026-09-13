import 'package:creatify_mobile/view/modules/bookings/widgets/profile_id_widget.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/claim_ambassador_commission_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AmbassadorReferralView extends ConsumerStatefulWidget {
  const AmbassadorReferralView({super.key});

  @override
  ConsumerState<AmbassadorReferralView> createState() => _AmbassadorReferralViewState();
}

class _AmbassadorReferralViewState extends ConsumerState<AmbassadorReferralView> {
  @override
  Widget build(BuildContext context) {
    final referralStates = ref.watch(fetchReferredUsersProvider);
    final userData = ref.watch(userControllerProvider);
    final claiming = ref.watch(claimAmbassadorCommissionProvider).isLoading;

    ref.listen(claimAmbassadorCommissionProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess('Referral Reward has been claimed. Check your Wallet', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ambassador Referral',
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
              SvgPicture.asset(AppImages.moneyWallet),
              24.0.height,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Total Earnings: ',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.black,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: data.stats?.totalCommissionEarned
                                ?.amountWithCurrency(userData.primaryCurrency ?? '') ??
                            'N/A',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              .0.height,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Unclaimed Earnings: ',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.black,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: data.stats?.unclaimedCommission
                                ?.amountWithCurrency(userData.primaryCurrency ?? '') ??
                            'N/A',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              12.0.height,

              // Withdraw Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: MainButton(
                  text: 'Claim Rewards',
                  isLoading: claiming,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: data.stats?.unclaimedCommission == 0
                      ? null
                      : () {
                          ref
                              .read(claimAmbassadorCommissionProvider.notifier)
                              .claimAmbassadorCommission();
                        },
                ),
              ),
              24.0.height,

              // Link and Copy Button
              ProfileIdWidget(
                profileId: data.stats?.referralCode ?? 'N/A',
              ),
              30.0.height,

              // MARK: Referral Balance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Referrals:',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.body,
                    ),
                  ),
                  Text(
                    data.stats?.totalReferrals.toString() ?? 'N/A',
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.black2,
                    ),
                  ),
                ],
              ),
              16.0.height,

              // MARK: Listed Referrals/How it Works
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                decoration: BoxDecoration(
                  color: AppColors.grey150,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    if (data.data?.isEmpty == true) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 16,
                          children: [
                            InstructionWidget(
                              instructionText: 'Share your ambassador code',
                              instructionSubText:
                                  'Tap Invite or Copy and send your ambassador referral code to friends who want to join Creatify',
                              image: AppImages.shareFilled,
                            ),
                            InstructionWidget(
                              instructionText: 'They sign up & complete onboarding',
                              instructionSubText:
                                  'Your referred user signs up, completes their profile and verifies their account\n(You can refer up to 5 people)',
                              image: AppImages.taskFilled,
                            ),
                            InstructionWidget(
                              instructionText: 'Earn commission for each referral',
                              instructionSubText:
                                  'Get a commission reward for every successfully onboarded and verified referral\nTap Claim to withdraw your earnings',
                              image: AppImages.rewardFilled,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final user = data.data?[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 10,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Text(
                                '${index + 1}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            title: Text(
                              user?.referredUser?.name ?? 'Unknown User',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppColors.black2,
                              ),
                            ),
                            trailing: Text(
                              user?.createdAt?.toFormattedDateWithYear() ?? 'N/A',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppColors.black2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => 8.0.height,
                        itemCount: data.data?.length ?? 0,
                      )
                    ]
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
