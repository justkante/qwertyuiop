import 'package:creatify_mobile/core/extensions/country_extensions.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/book_creator_view.dart';
import 'package:creatify_mobile/view/modules/bookings/creator_profile_view.dart';
import 'package:creatify_mobile/view/modules/home/rating/star_rating.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/modules/bookings/draft_bookings_view.dart';
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
  late bool _isFav;

  bool get _hasProfileImage {
    final img = widget.profile?.profileImage;
    return img != null && img.trim().isNotEmpty && img.trim().startsWith('http');
  }

  @override
  void initState() {
    super.initState();
    _isFav = widget.isFavorite || widget.profile?.isFavorited == true;
  }

  @override
  void didUpdateWidget(CreatorsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isFav = widget.isFavorite || widget.profile?.isFavorited == true;
  }

  void _toggleFav() {
    setState(() {
      _isFav = !_isFav;
    });
    if (widget.onFavoriteToggle != null) {
      widget.onFavoriteToggle!();
    }
  }

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

        NavigationService.instance.push(
          CreatorProfileView(
            profile: widget.profile,
            isFavorite: _isFav,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.surface,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _hasProfileImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: CachedImageHandler(
                              imageUrl: widget.profile!.profileImage!,
                              height: 80,
                              width: 80,
                            ),
                          )
                        : InitialAvatar(
                            initials: (widget.profile?.name != null && widget.profile!.name!.trim().isNotEmpty)
                                ? widget.profile!.name!.trim().split(' ').map((e) => e[0]).take(2).join('').toUpperCase()
                                : widget.profile?.initials ?? 'C',
                            padding: const EdgeInsets.all(24),
                            size: 24,
                          ),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: widget.profile?.isOnline == true ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ],
                ),
                16.0.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${widget.profile?.name} ${widget.profile?.countryCode?.flagFromCodeSync() ?? ''}",
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _toggleFav,
                            child: Icon(
                              _isFav ? Icons.favorite : Icons.favorite_outline,
                              size: 24,
                              color: _isFav ? Colors.red : AppColors.body,
                            ),
                          ),
                        ],
                      ),
                      4.0.height,
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.body),
                          4.0.width,
                          Text(
                            widget.profile?.location ?? 'Lagos, Nigeria',
                            style: context.textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.body),
                          ),
                        ],
                      ),
                      8.0.height,
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: (widget.profile?.categories ?? []).map((cat) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1EF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            cat.name ?? '',
                            style: const TextStyle(color: Color(0xFFFF6F61), fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        )).toList(),
                      ),
                      12.0.height,
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                          4.0.width,
                          Text(
                            '${widget.profile?.ratingsAndReviews?.averageRating ?? 0.0}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            ' (${widget.profile?.ratingsAndReviews?.totalReviews ?? 0} reviews)',
                            style: const TextStyle(color: AppColors.body, fontSize: 11),
                          ),
                        ],
                      ),
                      8.0.height,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time, color: Color(0xFF00BFA5), size: 14),
                            4.0.width,
                            Text(
                              'Last active: ${widget.profile?.lastSeenAt ?? 'Just now'}',
                              style: const TextStyle(color: Color(0xFF00BFA5), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            16.0.height,
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: MainButton(
                    text: 'View Profile →',
                    textColor: Colors.white,
                    fontSize: 14,
                    borderRadius: 24,
                    height: 44,
                    color: const Color(0xFF00796B),
                    onPressed: () {
                      NavigationService.instance.push(
                        CreatorProfileView(
                          profile: widget.profile,
                          isFavorite: _isFav,
                        ),
                      );
                    },
                  ),
                ),
                12.0.width,
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: () {
                       NavigationService.instance.push(
                         BookCreatorView(
                           creatorProfile: widget.profile ?? CreatorProfileDto(),
                         ),
                       );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00796B)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      fixedSize: const Size.fromHeight(44),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_outlined, size: 16, color: Color(0xFF00796B)),
                        8.0.width,
                        const Text('Invite', style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
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
  late bool _isFav;

  bool get _hasProfileImage {
    final img = widget.profile?.profileImage;
    return img != null && img.trim().isNotEmpty && img.trim().startsWith('http');
  }

  @override
  void initState() {
    super.initState();
    _isFav = widget.isFavorite || widget.profile?.isFavorited == true;
  }

  @override
  void didUpdateWidget(RecommendedCreatorsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isFav = widget.isFavorite || widget.profile?.isFavorited == true;
  }

  void _toggleFav() {
    setState(() {
      _isFav = !_isFav;
    });
    if (widget.onFavoriteToggle != null) {
      widget.onFavoriteToggle!();
    }
  }

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

        NavigationService.instance.push(
          CreatorProfileView(
            profile: widget.profile,
            isFavorite: _isFav,
          ),
        );
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.grey100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Center(
                  child: _hasProfileImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: CachedImageHandler(
                            imageUrl: widget.profile!.profileImage!,
                            height: 64,
                            width: 64,
                          ),
                        )
                      : InitialAvatar(
                          initials: (widget.profile?.name != null && widget.profile!.name!.trim().isNotEmpty)
                              ? widget.profile!.name!.trim().split(' ').map((e) => e[0]).take(2).join('').toUpperCase()
                              : widget.profile?.initials ?? 'C',
                          padding: const EdgeInsets.all(18),
                          size: 14,
                        ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _toggleFav,
                    child: Icon(
                      _isFav ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: _isFav ? Colors.red : AppColors.grey400,
                    ),
                  ),
                ),
              ],
            ),
            10.0.height,
            Text(
              (widget.profile?.categories?.isNotEmpty == true ? widget.profile!.categories!.first.name : null) ?? widget.profile?.name ?? 'Creator',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1B3131),
                fontWeight: FontWeight.bold,
              ),
            ),
            4.0.height,
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 14),
                2.0.width,
                Text(
                  '${widget.profile?.ratingsAndReviews?.averageRating ?? 0.0}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  ' (${widget.profile?.ratingsAndReviews?.totalReviews ?? 0})',
                  style: const TextStyle(color: AppColors.grey400, fontSize: 11),
                ),
              ],
            ),
            4.0.height,
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.grey400),
                4.0.width,
                Expanded(
                  child: Text(
                    widget.profile?.location ?? 'Lagos',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.grey400, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
