import 'package:creatify_mobile/view/modules/home/support_view.dart';
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
                  // Illustration
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

            // Table Header
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
                    '₦0',
                    'forever',
                    'Current Plan',
                    isCurrent: true,
                    onTap: () {},
                  ),
                  _buildPlanHeader(
                    context,
                    'Pro',
                    'For greater opportunities',
                    '₦3,000',
                    '/ month',
                    'Choose Plan',
                    isPopular: true,
                    onTap: () {
                       NavigationService.instance.push(const ChoosePlanView(initialIsAnnual: false));
                    },
                  ),
                  _buildPlanHeader(
                    context,
                    'Pro+',
                    'For serious growth',
                    '₦30,000',
                    '/ year',
                    'Choose Plan',
                    onTap: () {
                       NavigationService.instance.push(const ChoosePlanView(initialIsAnnual: true));
                    },
                  ),
                ],
              ),
            ),
            16.0.height,

            // Features List
            _buildSectionHeader('PROFILE & VISIBILITY'),
            _buildFeatureRow('Create a profile', true, true, true),
            _buildFeatureRow('Showcase your work', true, true, true),
            _buildFeatureRow('Higher profile visibility', false, true, true),

            _buildSectionHeader('JOBS & OPPORTUNITIES'),
            _buildFeatureRow('Browse and apply for jobs', true, true, true),
            _buildFeatureRow('Post job adverts (Recruiters)', false, true, true),
            _buildFeatureRow('Apply directly to job adverts', true, true, true),
            _buildFeatureRow('Job alerts', false, true, true),

            _buildSectionHeader('TOOLS & SUPPORT'),
            _buildFeatureRow('Priority support', false, false, true),
            _buildFeatureRow('Advanced insights\n(e.g. profile views, applications)', false, false, true),
            _buildFeatureRow('Early access to new features', false, false, true),

            32.0.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: MainButton(
                text: 'Choose a Plan',
                onPressed: () {
                   NavigationService.instance.push(const ChoosePlanView());
                },
              ),
            ),
            24.0.height,

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Still have questions? ",
                  style: context.textTheme.bodySmall?.copyWith(color: AppColors.body),
                ),
                GestureDetector(
                  onTap: () => NavigationService.instance.push(const SupportView()),
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
      ),
    );
  }

  Widget _buildPlanHeader(
    BuildContext context,
    String name,
    String subtitle,
    String price,
    String period,
    String buttonText, {
    bool isCurrent = false,
    bool isPopular = false,
    required VoidCallback onTap,
  }) {
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF00796B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Most popular',
                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            )
          else
            const SizedBox(height: 12),
          4.0.height,
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 8, color: AppColors.body)),
          8.0.height,
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Inter')),
          Text(period, style: const TextStyle(fontSize: 8, color: AppColors.body)),
          12.0.height,
          InkWell(
            onTap: isCurrent ? null : onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isCurrent ? AppColors.grey200 : const Color(0xFF00796B)),
              ),
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isCurrent ? AppColors.body : const Color(0xFF00796B),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFBABABA),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature, bool freeCheck, bool proCheck, bool proPlusCheck) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              feature,
              style: const TextStyle(fontSize: 10, color: Colors.black87, height: 1.3),
            ),
          ),
          _buildCheckIcon(freeCheck),
          _buildCheckIcon(proCheck),
          _buildCheckIcon(proPlusCheck),
        ],
      ),
    );
  }

  Widget _buildCheckIcon(bool checked) {
    return Expanded(
      flex: 2,
      child: Center(
        child: checked
            ? const Icon(Icons.check_circle, color: Color(0xFF00796B), size: 16)
            : const Text('—', style: TextStyle(color: AppColors.body, fontSize: 10)),
      ),
    );
  }
}
