import 'package:creatify_mobile/view/modules/home/support_view.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
                  // Placeholder for the 3D illustration
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC8E6C9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.star, color: Colors.orange, size: 32),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA7FFEB),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.workspace_premium, color: Color(0xFF00796B), size: 40),
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
                  ),
                  _buildPlanHeader(
                    context,
                    'Pro',
                    'For serious growth',
                    _getFormattedPrice(userData),
                    '/ month',
                    'Choose Plan',
                    isPopular: true,
                  ),
                ],
              ),
            ),
            16.0.height,

            // Features List
            _buildSectionHeader('PROFILE & VISIBILITY'),
            _buildFeatureRow('Create a profile', true, true),
            _buildFeatureRow('Showcase your work', true, true),
            _buildFeatureRow('Higher profile visibility', true, true),

            _buildSectionHeader('JOBS & OPPORTUNITIES'),
            _buildFeatureRow('Browse and apply for jobs', true, true),
            _buildFeatureRow('Post job adverts (Recruiters)', true, true),
            _buildFeatureRow('Apply directly to job adverts', true, true),
            _buildFeatureRow('Job alerts', true, true),

            _buildSectionHeader('TOOLS & SUPPORT'),
            _buildFeatureRow('Priority support', false, true),
            _buildFeatureRow('Advanced insights\n(e.g. profile views, applications)', false, true),
            _buildFeatureRow('Early access to new features', false, true),

            32.0.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: MainButton(
                text: 'Choose a Plan',
                onPressed: () => Navigator.of(context).pop(),
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
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: AppColors.body)),
          12.0.height,
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Inter')),
          Text(period, style: const TextStyle(fontSize: 9, color: AppColors.body)),
          12.0.height,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isCurrent ? AppColors.grey200 : const Color(0xFF00796B)),
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                color: isCurrent ? AppColors.body : const Color(0xFF00796B),
                fontSize: 10,
                fontWeight: FontWeight.bold,
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

  Widget _buildFeatureRow(String feature, bool freeCheck, bool proCheck) {
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
              style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.3),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: freeCheck
                  ? const Icon(Icons.check_circle, color: Color(0xFF00796B), size: 18)
                  : const Text('—', style: TextStyle(color: AppColors.body)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: proCheck
                  ? const Icon(Icons.check_circle, color: Color(0xFF00796B), size: 18)
                  : const Text('—', style: TextStyle(color: AppColors.body)),
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedPrice(dynamic userData) {
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

    return monthlyPrice.amountWithCurrency(currency);
  }
}
