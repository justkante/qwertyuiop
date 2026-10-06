import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';

class RateCardCarousel extends StatefulWidget {
  final List<CategoryItemDto> categories;
  final String primaryCurrency;
  const RateCardCarousel({
    super.key,
    required this.categories,
    required this.primaryCurrency,
  });

  @override
  State<RateCardCarousel> createState() => _RateCardCarouselState();
}

class _RateCardCarouselState extends State<RateCardCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text('Rates card not set up.', style: TextStyle(color: AppColors.body)),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.categories.length,
            onPageChanged: (idx) {
              setState(() {
                _currentPage = idx;
              });
            },
            itemBuilder: (context, index) {
              final category = widget.categories[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: AssetImage(AppImages.curtain),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.black.withOpacity(0.45), // Dark overlay over curtain
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      16.0.height,
                      Expanded(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: category.services?.length ?? 0,
                          separatorBuilder: (_, __) => 12.0.height,
                          itemBuilder: (context, sIdx) {
                            final pricing = category.services![sIdx];
                            final unitStr = pricing.pricingType?.split('_').last.toTitleCase() ?? 'Job';

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    pricing.serviceName ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                12.0.width,
                                Text(
                                  "${pricing.price.amountWithCurrency(widget.primaryCurrency)}/$unitStr",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        16.0.height,

        // Page Indicator Dots
        if (widget.categories.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.categories.length, (idx) {
              final isActive = _currentPage == idx;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 20 : 8,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFFF6F61) : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
      ],
    );
  }
}
