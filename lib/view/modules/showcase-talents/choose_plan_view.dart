import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChoosePlanView extends ConsumerStatefulWidget {
  final bool initialIsAnnual;
  const ChoosePlanView({super.key, this.initialIsAnnual = false});

  @override
  ConsumerState<ChoosePlanView> createState() => _ChoosePlanViewState();
}

class _ChoosePlanViewState extends ConsumerState<ChoosePlanView> {
  late bool _isAnnual;
  String _selectedTier = 'Pro'; // Default to Pro as per image

  @override
  void initState() {
    super.initState();
    _isAnnual = widget.initialIsAnnual;
  }

  @override
  Widget build(BuildContext context) {
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
          'Choose Plan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You’re one step closer\nto more opportunities',
                          style: context.textTheme.displayMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B3131),
                          ),
                        ),
                        8.0.height,
                        Text(
                          'Select the plan that works for you and start making the most of Creatify.',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.body,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                    AppImages.paperPlane,
                    height: 100,
                  ),
                ],
              ),
            ),

            // Toggle
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleButton('Monthly', !_isAnnual),
                    _buildToggleButton('Annual', _isAnnual, showBadge: true),
                  ],
                ),
              ),
            ),
            24.0.height,

            // Plans
            _buildPlanOption(
              'Free',
              'Get started on Creatify.',
              '₦0',
              'forever',
              ['Create a profile', 'Showcase your work', 'Browse and apply for jobs'],
              tier: 'Free',
            ),
            16.0.height,
            _buildPlanOption(
              'Pro',
              'For serious growth',
              _getFormattedPrice(userData),
              _isAnnual ? '/ year' : '/ month',
              [
                'Higher profile visibility',
                'Apply directly to job adverts',
                'Job alerts',
                'Post job adverts (Recruiters)',
                'Advanced insights',
                'Priority support',
                'And more...'
              ],
              tier: 'Pro',
              isPopular: true,
              showDiscount: _isAnnual,
            ),
            24.0.height,

            // Payment Method
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Payment Method',
                style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            8.0.height,
            _buildPaymentMethodTile(),
            24.0.height,

            // Disclaimer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: AppColors.body),
                    12.0.width,
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: context.textTheme.bodySmall?.copyWith(color: AppColors.body, height: 1.4),
                          children: [
                            const TextSpan(text: 'You can cancel your subscription at any time. By continuing, you agree to our '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            32.0.height,

            // Main Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: MainButton(
                text: 'Subscribe to $_selectedTier',
                onPressed: _selectedTier == 'Free' ? null : () {
                  // Handle subscription
                },
              ),
            ),

            // Footer
            16.0.height,
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 14, color: AppColors.body),
                  4.0.width,
                  Text(
                    'Secure payment powered by Stripe',
                    style: context.textTheme.bodySmall?.copyWith(color: AppColors.body),
                  ),
                ],
              ),
            ),
            40.0.height,
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool active, {bool showBadge = false}) {
    return GestureDetector(
      onTap: () => setState(() => _isAnnual = (label == 'Annual')),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))] : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: active ? Colors.black : AppColors.body,
              ),
            ),
            if (showBadge) ...[
              8.0.width,
              Text(
                'Save 17%',
                style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOption(
    String title,
    String subtitle,
    String price,
    String period,
    List<String> features, {
    required String tier,
    bool isPopular = false,
    bool showDiscount = false,
  }) {
    final isSelected = _selectedTier == tier;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => setState(() => _selectedTier = tier),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE0F2F1).withOpacity(0.3) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.body)),
                        16.0.height,
                        Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Inter')),
                        Text(period, style: const TextStyle(fontSize: 12, color: AppColors.body)),
                        if (showDiscount) ...[
                          8.0.height,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Save 17%', style: TextStyle(color: Color(0xFF00796B), fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        ...features.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Color(0xFF00796B), size: 16),
                              8.0.width,
                              Expanded(child: Text(f, style: const TextStyle(fontSize: 11, color: Colors.black87))),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  // Custom Radio
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.grey300, width: 2),
                    ),
                    child: isSelected ? Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary))) : null,
                  ),
                ],
              ),
            ),
            if (isPopular)
              Positioned(
                top: -10,
                right: 30,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00796B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Most popular', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.credit_card_outlined, color: AppColors.subHeading),
            ),
            16.0.width,
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add a payment method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Secure and encrypted', style: TextStyle(fontSize: 11, color: AppColors.body)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.body),
          ],
        ),
      ),
    );
  }

  String _getFormattedPrice(dynamic userData) {
    final String currency = (userData.primaryCurrency ?? 'NGN').toUpperCase();
    final String country = (userData.countryCode ?? 'NG').toUpperCase();

    double monthlyPrice;
    String symbol;

    if (country == 'NG' || currency == 'NGN') {
      monthlyPrice = 10000;
      symbol = '₦';
    } else if (country == 'GB' || currency == 'GBP') {
      monthlyPrice = 9.99;
      symbol = '£';
    } else {
      final rates = {
        'USD': 1.27, 'EUR': 1.18, 'CAD': 1.74, 'AUD': 1.91, 'BRL': 6.50,
        'AED': 4.66, 'SGD': 1.71, 'GHS': 18.5, 'KES': 165.0, 'ZAR': 23.5,
      };
      final rate = rates[currency] ?? 1.27;
      monthlyPrice = 9.99 * rate;

      const symbols = {
        'USD': '$', 'EUR': '€', 'CAD': 'CA$', 'AUD': 'A$', 'BRL': 'R$',
        'AED': 'د.إ', 'SGD': 'S$', 'GHS': 'GH₵', 'KES': 'KSh', 'ZAR': 'R',
      };
      symbol = symbols[currency] ?? currency;
    }

    final price = _isAnnual ? monthlyPrice * 10 : monthlyPrice;
    final formattedAmount = price.amountInt(
      includeCommas: true,
      minDecimalPlaces: price >= 100 ? 0 : 2,
    );

    final isSymbolPrefixed = !['kr', 'лв', 'Kč', 'Ft', 'Fr', 'zł', 'lei'].contains(symbol.toLowerCase());

    return isSymbolPrefixed ? "$symbol$formattedAmount" : "$formattedAmount $symbol";
  }
}
