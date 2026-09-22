import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/data/models/responses/onboarding_status_dto.dart';
import 'package:creatify_mobile/data/models/responses/user_dto.dart';
import 'package:creatify_mobile/core/utils/profile_strength_utils.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';

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
          // const Icon(Icons.chevron_right, color: AppColors.body, size: 20), // Removed arrow
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label, bool completed) {
    return Row(
      children: [
        Icon(
          completed ? Icons.star : Icons.star_border, // Stars instead of circles
          color: completed ? const Color(0xFF00BFA5) : AppColors.grey300,
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.grey100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            12.0.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 13, color: AppColors.body, fontWeight: FontWeight.w500), // Increased from 11
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20, // Increased from 18
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B3131),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.grey300, size: 16),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1B3131),
          ),
        ),
        if (onSeeAll != null)
          InkWell(
            onTap: onSeeAll,
            child: Row(
              children: [
                const Text(
                  'See all',
                  style: TextStyle(color: Color(0xFF00BFA5), fontSize: 13, fontWeight: FontWeight.bold),
                ),
                4.0.width,
                const Icon(Icons.chevron_right, color: Color(0xFF00BFA5), size: 16),
              ],
            ),
          ),
      ],
    );
  }
}
