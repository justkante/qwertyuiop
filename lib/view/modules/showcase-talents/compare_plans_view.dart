import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/choose_plan_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';

class ComparePlansView extends ConsumerStatefulWidget {
  const ComparePlansView({super.key});

  @override
  ConsumerState<ComparePlansView> createState() => _ComparePlansViewState();
}

class _ComparePlansViewState extends ConsumerState<ComparePlansView> {
  String _selectedPlan = 'Pro';

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final currency = userData.primaryCurrency ?? 'NGN';
    final proMonthlyPrice = 10000.amountWithCurrency(currency);
    final subscriptionAsync = ref.watch(fetchMySubscriptionProvider);
    final isPro = subscriptionAsync.value?.hasSubscription == true &&
                  subscriptionAsync.value?.isActive == true;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Compare Plans',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find the plan that\nworks for you',
                          style: context.textTheme.displayMedium?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B3131),
                          ),
                        ),
                        8.0.height,
                        Text(
                          'Choose the features that help you get the most out of Creatify.',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.body,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                         Container(
                           padding: const EdgeInsets.all(12),
                           decoration: const BoxDecoration(color: Color(0xFFE0F2F1), shape: BoxShape.circle),
                           child: const Icon(Icons.workspace_premium, color: Color(0xFF00BFA5), size: 48),
                         ),
                         Positioned(
                           top: 5,
                           right: 5,
                           child: Container(
                             padding: const EdgeInsets.all(4),
                             decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                             child: const Icon(Icons.star, color: Colors.orange, size: 20),
                           ),
                         ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            24.0.height,

            // Table Header Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 4, child: SizedBox()),
                  _buildPlanHeader(
                    context,
                    title: 'Free',
                    subtitle: 'Get started',
                    price: '',
                    period: '',
                    buttonText: !isPro ? 'Current Plan' : 'Free Plan',
                    isSelected: _selectedPlan == 'Free',
                    isCurrent: !isPro,
                    onTap: () {
                      setState(() => _selectedPlan = 'Free');
                    },
                    onButtonTap: () {
                      setState(() => _selectedPlan = 'Free');
                      if (!isPro) {
                        ToastDialog.showSuccess('You are currently on the Free plan', context);
                      }
                    },
                  ),
                  8.0.width,
                  _buildPlanHeader(
                    context,
                    title: 'Pro',
                    subtitle: 'For greater opportunities',
                    price: proMonthlyPrice,
                    period: '/ month',
                    buttonText: isPro ? 'Current Plan' : 'Choose Plan',
                    isSelected: _selectedPlan == 'Pro',
                    isCurrent: isPro,
                    onTap: () {
                      setState(() => _selectedPlan = 'Pro');
                    },
                    onButtonTap: () {
                      if (_selectedPlan != 'Pro') {
                        setState(() => _selectedPlan = 'Pro');
                      } else {
                        if (isPro) {
                          ToastDialog.showSuccess('You are currently on the Pro plan', context);
                        } else {
                          NavigationService.instance.push(const ChoosePlanView(initialIsAnnual: false));
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            16.0.height,

            // Features List
            _buildSectionHeader('PROFILE & VISIBILITY'),
            _buildFeatureRow('Create a profile', true, true),
            _buildFeatureRow('Showcase your work', true, true),
            _buildFeatureRow('Higher profile visibility', false, true),

            _buildSectionHeader('JOBS & OPPORTUNITIES'),
            _buildFeatureRow('Browse and apply for jobs', true, true),
            _buildFeatureRow('Apply directly to job adverts', false, true),
            _buildFeatureRow('Job alerts', false, true),

            _buildSectionHeader('INSIGHTS & SUPPORT'),
            _buildFeatureRow('Advanced insights', true, true),
            _buildFeatureRow('Priority support', false, true),

            40.0.height,
          ],
        ),
      ),
    );
  }

  Widget _buildPlanHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String price,
    required String period,
    required String buttonText,
    required bool isSelected,
    required bool isCurrent,
    required VoidCallback onTap,
    required VoidCallback onButtonTap,
  }) {
    return Expanded(
      flex: 2,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFE0F2F1).withValues(alpha: 0.3)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.grey200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: isSelected ? AppColors.primary : Colors.black,
                ),
              ),
              2.0.height,
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: AppColors.body),
              ),
              6.0.height,
              if (price.isNotEmpty)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    price,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Inter',
                    ),
                  ),
                )
              else
                const SizedBox(height: 20),
              if (period.isNotEmpty)
                Text(
                  period,
                  style: const TextStyle(fontSize: 10, color: AppColors.body),
                )
              else
                const SizedBox(height: 12),
              14.0.height,
              SizedBox(
                width: double.infinity,
                child: MainButton(
                  text: buttonText,
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  color: isCurrent ? AppColors.grey200 : AppColors.primary,
                  textColor: isCurrent ? AppColors.heading : Colors.white,
                  onPressed: onButtonTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.body,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String title, bool free, bool pro) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF1B3131)))),
          Expanded(flex: 2, child: Center(child: _buildCheck(free))),
          Expanded(flex: 2, child: Center(child: _buildCheck(pro))),
        ],
      ),
    );
  }

  Widget _buildCheck(bool available) {
    if (available) {
      return const Icon(Icons.check, color: Color(0xFF00796B), size: 20);
    }
    return const Icon(Icons.remove, color: AppColors.grey300, size: 20);
  }
}
