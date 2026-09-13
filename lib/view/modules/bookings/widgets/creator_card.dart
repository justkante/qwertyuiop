import 'package:creatify_mobile/core/extensions/country_extensions.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/creator_profile_view.dart';
import 'package:creatify_mobile/view/modules/home/rating/star_rating.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/cache_image_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// MARK: Creator Card Widget
class CreatorsCard extends ConsumerStatefulWidget {
  final Function()? onFavoriteToggle;
  final bool isFavorite;
  final bool isLoading;
  final CreatorProfileDto? profile;
  const CreatorsCard({
    super.key,
    this.isFavorite = false,
    this.profile,
    this.isLoading = false,
    this.onFavoriteToggle,
  });

  @override
  ConsumerState<CreatorsCard> createState() => _CreatorsCardState();
}

class _CreatorsCardState extends ConsumerState<CreatorsCard> {
  @override
  Widget build(BuildContext context) {
    // User Controller
    final userData = ref.watch(userControllerProvider);

    return InkWell(
      onTap: () {
        mixpanel.trackEvent('Creator Profile Viewed', properties: {
          'creator_id': widget.profile?.id ?? '',
          'creator_name': widget.profile?.name ?? '',
          'categories':
              widget.profile?.categories?.map((category) => category.name).join(', ') ?? '',
        });

        context.push(
          CreatorProfileView(
            profile: widget.profile,
            isFavorite: widget.isFavorite,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 10, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.surface,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                widget.profile?.profileImage != null
                    ? CachedImageHandler(
                        imageUrl: widget.profile?.profileImage ?? '',
                        height: 56,
                        width: 56,
                      )
                    : InitialAvatar(
                        initials: widget.profile?.initials ?? '',
                        padding: const EdgeInsets.all(14),
                        size: 16,
                      ),
                8.0.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "${widget.profile?.name} ${widget.profile?.countryCode?.flagFromCodeSync() ?? ''}",
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textTheme.bodyLarge?.copyWith(
                                      fontSize: 15,
                                      color: AppColors.subHeading,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (widget.profile?.isPremium == true) ...[
                                  3.0.width,
                                  SvgPicture.asset(
                                    AppImages.blueTick,
                                    width: 16,
                                    height: 16,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Text(
                          //   "${num.parse(widget.profile?.categories?.first?.services?.first?.price ?? '0').amountWithCurrency('ngn')}/hr",
                          //   textAlign: TextAlign.right,
                          //   style: context.textTheme.bodySmall?.copyWith(
                          //     color: AppColors.spot500,
                          //     fontFamily: FontFamily.inter,
                          //     fontWeight: FontWeight.w500,
                          //   ),
                          // ),
                        ],
                      ),
                      2.0.height,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.profile?.categories?.isEmpty == true
                              ? Text(
                                  'No Creator Niche',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                  ),
                                )
                              : RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    text: widget.profile?.categories?.first.name ?? '',
                                    style: context.textTheme.bodySmall?.copyWith(
                                      fontSize: 10,
                                      color: AppColors.highlightCoral,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: widget.profile?.categories
                                                ?.map((category) => category.name)
                                                .join(' | ')
                                                .substring(widget
                                                        .profile?.categories?.first.name?.length ??
                                                    0) ??
                                            '',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontSize: 10,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                          4.0.height,

                          // Star Rating
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '(${widget.profile?.ratingsAndReviews?.averageRating ?? 0.0})',
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: AppColors.subHeading,
                                ),
                              ),
                              6.0.width,
                              StarRating(
                                rating: widget.profile?.ratingsAndReviews?.averageRating ?? 0.0,
                                starCount: 5,
                                starSize: 12,
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            12.0.height,
            Row(
              children: [
                if (userData.id != null) ...[
                  InkWell(
                    onTap: widget.onFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.surface,
                        ),
                      ),
                      child: widget.isLoading
                          ? CircularProgressIndicator.adaptive(
                              constraints: BoxConstraints.tight(const Size(16, 16)),
                              padding: const EdgeInsets.all(12.0),
                              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                              strokeWidth: 2,
                            )
                          : SvgPicture.asset(
                              widget.isFavorite || widget.profile?.isFavorited == true
                                  ? AppImages.favoriteFill
                                  : AppImages.favorite,
                              width: 27,
                              height: 27,
                            ),
                    ),
                  ),
                  12.0.width,
                ],
                Expanded(
                  child: MainButton(
                    text: 'View Profile',
                    textColor: AppColors.subHeading,
                    borderRadius: 8,
                    color: AppColors.grey100,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    onPressed: () {
                      context.push(
                        CreatorProfileView(
                          profile: widget.profile,
                          isFavorite: widget.isFavorite || widget.profile?.isFavorited == true,
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// MARK: Recommended Creators Card Widget
class RecommendedCreatorsCard extends ConsumerStatefulWidget {
  final Function()? onFavoriteToggle;
  final bool isFavorite;
  final bool isLoading;
  final CreatorProfileDto? profile;
  const RecommendedCreatorsCard({
    super.key,
    this.isFavorite = false,
    this.profile,
    this.isLoading = false,
    this.onFavoriteToggle,
  });

  @override
  ConsumerState<RecommendedCreatorsCard> createState() => _RecommendedCreatorsCardState();
}

class _RecommendedCreatorsCardState extends ConsumerState<RecommendedCreatorsCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        mixpanel.trackEvent('Recommended Creator Profile Viewed', properties: {
          'creator_id': widget.profile?.id ?? '',
          'creator_name': widget.profile?.name ?? '',
          'categories':
              widget.profile?.categories?.map((category) => category.name).join(', ') ?? '',
        });

        context.push(
          CreatorProfileView(
            profile: widget.profile,
            isFavorite: widget.isFavorite,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.surface,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              offset: Offset(8, 7),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  widget.profile?.profileImage != null
                      ? CachedImageHandler(
                          imageUrl: widget.profile?.profileImage ?? '',
                          height: 40,
                          width: 40,
                        )
                      : InitialAvatar(
                          initials: widget.profile?.initials ?? '',
                          padding: const EdgeInsets.all(14),
                          size: 12,
                        ),
                  8.0.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.profile?.name ?? 'Temiloluwa Otedola',
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.bodyLarge?.copyWith(
                                        fontSize: 15,
                                        color: AppColors.subHeading,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (widget.profile?.isPremium == true) ...[
                                    3.0.width,
                                    SvgPicture.asset(
                                      AppImages.blueTick,
                                      width: 16,
                                      height: 16,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        2.0.height,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.profile?.categories?.isEmpty == true
                                ? Text(
                                    'No Creator Niche',
                                    style: context.textTheme.bodySmall?.copyWith(
                                      fontSize: 10,
                                    ),
                                  )
                                : RichText(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      text: widget.profile?.categories?.first.name ?? '',
                                      style: context.textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                        color: AppColors.highlightCoral,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: widget.profile?.categories
                                                  ?.map((category) => category.name)
                                                  .join(' | ')
                                                  .substring(widget.profile?.categories?.first.name
                                                          ?.length ??
                                                      0) ??
                                              '',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontSize: 10,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
