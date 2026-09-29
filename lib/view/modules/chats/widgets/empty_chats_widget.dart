import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EmptyChatsWidget extends ConsumerWidget {
  final String filter;
  const EmptyChatsWidget({super.key, this.filter = 'All'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 150), // Adequate bottom padding to prevent cutoff
      child: Column(
        children: [
          20.0.height,
          // Illustration
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(color: Colors.teal.shade50.withOpacity(0.3), shape: BoxShape.circle),
                ),
                const Icon(Icons.forum_outlined, size: 80, color: Color(0xFF00796B)),
              ],
            ),
          ),
          24.0.height,
          Text(
            filter == 'All' ? 'No chats yet' : 'No $filter chats',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1B3131)),
          ),
          8.0.height,
          const Text(
            'Messaging is available for confirmed bookings - book or get booked to start chatting.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.body, fontSize: 13, height: 1.5),
          ),
          28.0.height,

          MainButton(
            text: 'Find Opportunities',
            borderRadius: 24,
            fontSize: 14,
            padding: const EdgeInsets.symmetric(vertical: 14),
            onPressed: () {
               ref.read(navBarController.notifier).index = 1; // Go to Discover/Search
            },
          ),
          32.0.height,

          // Tip Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FDFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Color(0xFF00BFA5), size: 20),
                    8.0.width,
                    const Text('Tip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B3131))),
                  ],
                ),
                8.0.height,
                const Text(
                  'When you apply for a job or receive a booking, you can message the other party here.',
                  style: TextStyle(color: AppColors.body, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          60.0.height,
        ],
      ),
    );
  }
}
