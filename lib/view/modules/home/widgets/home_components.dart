import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/data/models/responses/onboarding_status_dto.dart';
import 'package:creatify_mobile/data/models/responses/user_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/profile_strength_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfileStrengthWidget extends StatelessWidget {
  final UserDto user;
  final OnboardingStatusDto? onboardingStatus;
  final CreatorProfileDto? creatorProfile;

  const ProfileStrengthWidget({
    super.key,
    required this.user,
    this.onboardingStatus,
    this.creatorProfile,
  });

  @override
  Widget build(BuildContext context) {
    final strength = ProfileStrengthUtils.calculateStrength(
      user: user,
      onboardingStatus: onboardingStatus,
      creatorProfile: creatorProfile,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile strength',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B3131)),
                    ),
                    Text(
                      '${strength.toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                    ),
                  ],
                ),
                12.0.height,
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: strength / 100,
                    minHeight: 10,
                    backgroundColor: AppColors.grey100,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                12.0.height,
                const Text(
                  'A complete profile gets 3x more views!',
                  style: TextStyle(fontSize: 11, color: AppColors.body),
                ),
              ],
            ),
          ),
          16.0.width,
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(top: 18), // Pushed down to occupy empty bottom space
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCheckItem('Portfolio uploaded', onboardingStatus?.steps?.portfolio == 'completed'),
                  8.0.height,
                  _buildCheckItem('Availability set', onboardingStatus?.steps?.availability == 'completed'),
                  8.0.height,
                  _buildCheckItem('KYC verified', onboardingStatus?.steps?.kyc == 'completed'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label, bool completed) {
    return Row(
      children: [
        Icon(
          Icons.star,
          color: completed ? const Color(0xFFFFD700) : AppColors.grey300,
          size: 14,
        ),
        6.0.width,
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF1B3131), fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 165,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: bgColor.withValues(alpha: 0.7)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            10.0.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: AppColors.body, fontWeight: FontWeight.w600, height: 1.1),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  2.0.height,
                  Text(
                    value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B3131)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 14, color: AppColors.grey300),
          ],
        ),
      ),
    );
  }
}
