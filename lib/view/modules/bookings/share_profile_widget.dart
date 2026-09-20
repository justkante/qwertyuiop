import 'package:creatify_mobile/core/utils/app_func_utils.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/expandable_profile_image.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/profile_id_widget.dart';
import 'package:creatify_mobile/view/modules/home/rating/star_rating.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart' as snackbar;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShareProfileWidget extends StatefulWidget {
  const ShareProfileWidget({
    super.key,
    required this.profile,
    this.self = false,
  });

  final CreatorProfileDto? profile;
  final bool self;

  @override
  State<ShareProfileWidget> createState() => _ShareProfileWidgetState();
}

class _ShareProfileWidgetState extends State<ShareProfileWidget> {
  @override
  Widget build(BuildContext context) {
    final profileUrl = 'https://creatifyapp.com/profile/${widget.profile?.profileId ?? widget.profile?.id}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ),
        ),

        // MARK: Profile Image
        ExpandableProfileImage(
          imageUrl: widget.profile?.profileImage,
          initials: widget.profile?.initials ?? '',
          size: 72,
          initialsFallback: Center(
            child: InitialAvatar(
              initials: widget.profile?.initials ?? '',
              padding: const EdgeInsets.all(20),
              size: 26,
            ),
          ),
        ),
        8.0.height,
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.profile?.name ?? "User",
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.profile?.isPremium == true) ...[
                4.0.width,
                SvgPicture.asset(
                  AppImages.blueTick,
                  width: 16,
                  height: 16,
                ),
              ],
            ],
          ),
        ),
        8.0.height,

        // MARK: Rating
        Center(
          child: StarRating(
            rating: widget.profile?.ratingsAndReviews?.averageRating ?? 0.0,
            starCount: 5,
            starSize: 16,
          ),
        ),
        18.0.height,

        // MARK: Share Profile
        Text(
          "Share ${widget.self ? 'Your ' : ''}Profile",
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        8.0.height,
        Text(
          "Know someone who might be interested? Share ${widget.self ? 'your ' : 'this '}profile link and let them check it out.",
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
        16.0.height,

        // Link and Copy Button
        ProfileIdWidget(
          profileId: profileUrl,
        ),
        24.0.height,

        // Social Media Icons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(FontAwesomeIcons.whatsapp, const Color(0xFF25D366), 'WhatsApp', () {
              AppUtils.shareLink("Check out ${widget.profile?.name}'s profile on Creatify: $profileUrl", context);
            }),
            20.0.width,
            _buildSocialIcon(FontAwesomeIcons.instagram, const Color(0xFFE4405F), 'Instagram', () {
               // Instagram usually needs direct link share
               AppUtils.shareLink(profileUrl, context);
            }),
            20.0.width,
            _buildSocialIcon(FontAwesomeIcons.xTwitter, Colors.black, 'X', () {
               AppUtils.shareLink("Check out ${widget.profile?.name}'s profile on Creatify: $profileUrl", context);
            }),
            20.0.width,
            _buildSocialIcon(FontAwesomeIcons.facebook, const Color(0xFF1877F2), 'Facebook', () {
               AppUtils.shareLink(profileUrl, context);
            }),
          ],
        ),
        32.0.height,

        // Share Button
        MainButton(
          text: 'Share',
          padding: const EdgeInsets.symmetric(vertical: 12),
          onPressed: () async {
             final message = "Check out ${widget.profile?.name}'s profile on Creatify: $profileUrl";
             await AppUtils.shareLink(message, context);
          },
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(icon, color: color, size: 24),
          ),
        ),
        4.0.height,
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.body)),
      ],
    );
  }
}
