import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/choose_plan_view.dart';

class ComparePlansView extends ConsumerWidget {
  const ComparePlansView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userControllerProvider);
    final currency = userData.primaryCurrency ?? 'NGN';
    final proMonthlyPrice = 10000.amountWithCurrency(currency);

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

            // Table Header (Free and Pro only)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 3, child: SizedBox()),
                  _buildPlanHeader(
                    context,
                    'Free',
                    'Get started',
                    'Free',
                    '',
                    'Current Plan',
                    isCurrent: true,
                    onTap: () {},
                  ),
                  _buildPlanHeader(
                    context,
                    'Pro',
                    'For greater opportunities',
                    proMonthlyPrice,
                    '/ month',
                    'Choose Plan',
                    isPopular: true,
                    onTap: () {
                       NavigationService.instance.push(const ChoosePlanView(initialIsAnnual: false));
                    },
                  ),
                ],
              ),
            ),
            16.0.height,

            // Features List (Pro+ and Post job adverts removed, Advanced insights ticked for both)
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

  Widget _buildPlanHeader(BuildContext context, String title, String subtitle, String price, String period, String buttonText, {bool isPopular = false, bool isCurrent = false, required VoidCallback onTap}) {
    return Expanded(
      flex: 3,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPopular ? const Color(0xFFE0F2F1).withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isPopular ? AppColors.primary : AppColors.grey200),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            4.0.height,
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Inter')),
            if (period.isNotEmpty)
              Text(period, style: const TextStyle(fontSize: 10, color: AppColors.body)),
            12.0.height,
            SizedBox(
              width: double.infinity,
              child: MainButton(
                text: buttonText,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: isCurrent ? AppColors.grey200 : AppColors.primary,
                textColor: isCurrent ? AppColors.heading : Colors.white,
                onPressed: onTap,
              ),
            ),
          ],
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
          Expanded(flex: 3, child: Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF1B3131)))),
          Expanded(flex: 1, child: Center(child: _buildCheck(free))),
          Expanded(flex: 1, child: Center(child: _buildCheck(pro))),
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
