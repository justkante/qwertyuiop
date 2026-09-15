import 'package:creatify_mobile/data/models/responses/subcriptions_plans_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/cancel_subscriotion_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/choose_plan_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/compare_plans_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/make_subscription_payment_vm.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:creatify_mobile/view/modules/home/support_view.dart';

class ManageSubscriptionView extends ConsumerStatefulWidget {
  const ManageSubscriptionView({super.key});

  @override
  ConsumerState<ManageSubscriptionView> createState() => _ManageSubscriptionViewState();
}

class _ManageSubscriptionViewState extends ConsumerState<ManageSubscriptionView> {
  int? _selectedPlanIndex;

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final subscriptionDetails = ref.watch(fetchMySubscriptionProvider);
    final plansAsync = ref.watch(fetchSubscriptionPlansProvider);

    ref.listen(autoRenewSubscriptionProvider, (_, value) {
      if (value is AsyncData) {}
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Manage Subscription',
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: subscriptionDetails.when(
        data: (data) {
          if (data.data == null) {
            return plansAsync.when(
              data: (plans) => _buildNoSubscriptionView(plans, userData),
              loading: () => const Center(child: CircularProgressIndicator.adaptive()),
              error: (e, s) => Center(child: Text('Error loading plans: $e')),
            );
          }

          bool autoRenew = data.data?.autoRenew ?? false;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // MARK: Current Plan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.highlightBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // MARK: Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Current Plan',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        AppImages.indicator,
                                        colorFilter: data.isActive == true
                                            ? AppColors.highlightGreen.colorFilterMode()
                                            : AppColors.highlightRed.colorFilterMode(),
                                        width: 6,
                                        height: 6,
                                      ),
                                      4.0.width,
                                      Text(
                                        data.isActive == true ? 'Active' : 'Inactive',
                                        style: context.textTheme.bodySmall?.copyWith(
                                          color: data.isActive == true
                                              ? AppColors.highlightGreen
                                              : AppColors.highlightRed,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // MARK: Plan Details
                            16.0.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${data.data?.plan?.name} Plan',
                                      style: context.textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                        color: Colors.white.withOpacity(0.5),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    3.0.height,
                                    Text(
                                      num.tryParse(data.data?.amount ?? '0')
                                          ?.amountWithCurrency(userData.primaryCurrency ?? '') ?? '0.00',
                                      style: context.textTheme.headlineSmall?.copyWith(
                                        fontSize: 21,
                                        fontFamily: FontFamily.inter,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Expiry Date',
                                      style: context.textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                        color: Colors.white.withOpacity(0.5),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    3.0.height,
                                    Text(
                                      data.data?.expiresAt?.toFormattedDateWithYear() ?? '',
                                      style: context.textTheme.headlineSmall?.copyWith(
                                        fontSize: 21,
                                        fontFamily: FontFamily.inter,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            16.0.height,
                          ],
                        ),
                      ),

                      // MARK: Auto Renew Toggle
                      16.0.height,
                      Visibility(
                        visible: false,
                        child: Row(
                          children: [
                            Switch(
                              value: autoRenew,
                              onChanged: (value) {
                                setState(() {
                                  autoRenew = value;
                                });

                                ref
                                    .read(autoRenewSubscriptionProvider.notifier)
                                    .toggleAutoRenewSubscription(
                                      id: data.data?.id ?? '',
                                      autoRenew: value,
                                    );
                              },
                              activeThumbColor: Colors.white,
                              inactiveTrackColor: AppColors.grey200,
                              activeTrackColor: AppColors.primary,
                            ),
                            8.0.width,
                            Text(
                              'Auto Renew',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.black2,
                              ),
                            ),
                            if (ref.watch(autoRenewSubscriptionProvider).isLoading) ...[
                              8.0.width,
                              LoadingAnimationWidget.hexagonDots(color: AppColors.black2, size: 16),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Cancel Subscription Button
                MainButton(
                  text: 'Cancel Subscription',
                  onPressed: () {
                    AppBottomSheet.showBottomSheet(
                      context,
                      widget: CancelSubscriptionSheet(
                        subscriptionId: data.data?.id,
                      ),
                    );
                  },
                ),
                48.0.height,
              ],
            ),
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
              8.0.height,
              const Text('Loading Subscription Details...'),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildNoSubscriptionView(List<SubscriptionsPlanDto> plans, dynamic userData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Illustration
          Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.teal.shade50.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   // Placeholder for the 3D illustration
                   SvgPicture.asset(
                     AppImages.almostThere,
                     height: 140,
                   ),
                ],
              ),
            ),
          ),
          24.0.height,

          // Titles
          Text(
            "You’re not on a subscription plan yet",
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          8.0.height,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Upgrade to unlock more ways to grow, get discovered and do more on Creatify.",
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.body,
                fontSize: 14,
              ),
            ),
          ),
          32.0.height,

          // Features Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFeatureItem(Icons.person_outline, 'Boost your visibility', const Color(0xFF00BFA5)),
              _buildFeatureItem(Icons.list_alt, 'Access more opportunities', const Color(0xFF2196F3)),
              _buildFeatureItem(Icons.shield_outlined, 'Stand out to recruiters', const Color(0xFFFFA000)),
              _buildFeatureItem(Icons.flash_on_outlined, 'Get the most out of Creatify', const Color(0xFFF06292)),
            ],
          ),
          40.0.height,

          // Plan Cards
          _buildPlanCard(
            title: 'Monthly Plan',
            subtitle: 'Flexible. Upgrade or cancel anytime.',
            price: _getFormattedPrice(userData, false),
            badge: 'Most popular',
            isSelected: _selectedPlanIndex == 0,
            onTap: () => setState(() => _selectedPlanIndex = 0),
          ),
          16.0.height,
          _buildPlanCard(
            title: 'Annual Plan',
            subtitle: 'Best value for long-term growth.',
            price: _getFormattedPrice(userData, true),
            badge: 'Save 17%',
            badgeColor: const Color(0xFFC8E6C9),
            isSelected: _selectedPlanIndex == 1,
            onTap: () => setState(() => _selectedPlanIndex = 1),
          ),
          16.0.height,

          // Compare Plans
          _buildActionItem(
            icon: Icons.bar_chart,
            title: 'Compare Plans',
            subtitle: 'See what\'s included in each plan',
            onTap: () {
              context.push(const ComparePlansView());
            },
          ),
          32.0.height,

          // Main Button
          MainButton(
            text: 'Choose a Plan',
            color: AppColors.primary,
            onPressed: _selectedPlanIndex == null
                ? null
                : () {
                    final selectedInterval = _selectedPlanIndex == 0 ? 'monthly' : 'annually';
                    context.push(ChoosePlanView(initialIsAnnual: selectedInterval == 'annually'));
                  },
          ),
          24.0.height,

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Need help? ",
                style: context.textTheme.bodySmall?.copyWith(color: AppColors.body),
              ),
              GestureDetector(
                onTap: () => context.push(const SupportView()),
                child: Text(
                  "Contact Support",
                  style: context.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF00BFA5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          40.0.height,
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        8.0.height,
        SizedBox(
          width: 70,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              height: 1.2,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    {required String title,
    required String subtitle,
    required String price,
    String? badge,
    Color? badgeColor,
    required bool isSelected,
    required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F2F1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (badge != null) ...[
                        8.0.width,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor ?? const Color(0xFFB2DFDB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badge,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: badgeColor != null ? Colors.green.shade700 : AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  4.0.height,
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.body,
                      fontSize: 12,
                    ),
                  ),
                  12.0.height,
                  Text(
                    price,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: FontFamily.inter,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isSelected ? AppColors.primary : AppColors.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    {required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.subHeading, size: 20),
            ),
            16.0.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.body,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.body, size: 20),
          ],
        ),
      ),
    );
  }

  String _getFormattedPrice(dynamic userData, bool isAnnual) {
    final String currency = (userData.primaryCurrency ?? 'NGN').toUpperCase();
    final String country = (userData.countryCode ?? 'NG').toUpperCase();

    double monthlyPrice;

    if (country == 'NG' || currency == 'NGN') {
      monthlyPrice = 10000;
    } else if (country == 'GB' || currency == 'GBP') {
      monthlyPrice = 9.99;
    } else {
      final rates = {
        'USD': 1.27, 'EUR': 1.18, 'CAD': 1.74, 'AUD': 1.91, 'BRL': 6.50,
        'AED': 4.66, 'SGD': 1.71, 'GHS': 18.5, 'KES': 165.0, 'ZAR': 23.5,
      };
      final rate = rates[currency] ?? 1.27;
      monthlyPrice = 9.99 * rate;
    }

    final price = isAnnual ? monthlyPrice * 10 : monthlyPrice;
    final String unitText = isAnnual ? 'year' : 'month';

    return "${price.amountWithCurrency(currency)} / $unitText";
  }
}
