import 'dart:developer';

import 'package:creatify_mobile/view/modules/bookings/booking_details_view.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';

/// Social Media Message Style Banner (WhatsApp, Snapchat, TikTok style heads-up notification)
class SocialMessageBanner extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final VoidCallback onDismiss;
  final VoidCallback onView;

  const SocialMessageBanner({
    super.key,
    required this.bookingData,
    required this.onDismiss,
    required this.onView,
  });

  @override
  State<SocialMessageBanner> createState() => _SocialMessageBannerState();
}

class _SocialMessageBannerState extends State<SocialMessageBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    _controller.forward();

    // Auto dismiss after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) _dismiss();
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.bookingData['title']?.toString() ??
        widget.bookingData['job_description']?.toString() ??
        widget.bookingData['message']?.toString() ??
        'New Booking Request';
    final price = widget.bookingData['price']?.toString() ??
        widget.bookingData['total_price']?.toString() ??
        '';
    final recruiterName = widget.bookingData['recruiter_name']?.toString() ??
        widget.bookingData['sender_name']?.toString() ??
        'Recruiter';

    final style = widget.bookingData['social_style']?.toString() ?? 'whatsapp';

    // Social media styling configs
    Color primaryColor;
    String platformName;
    IconData platformIcon;
    List<Color> gradientColors;

    switch (style) {
      case 'snapchat':
        primaryColor = const Color(0xFFFFFC00);
        platformName = 'Snapchat';
        platformIcon = Icons.bolt_rounded;
        gradientColors = [const Color(0xFFFFFC00), const Color(0xFFFFD100)];
        break;
      case 'tiktok':
        primaryColor = const Color(0xFFFE2C55);
        platformName = 'TikTok';
        platformIcon = Icons.play_arrow_rounded;
        gradientColors = [const Color(0xFFFE2C55), const Color(0xFF25F4EE)];
        break;
      case 'whatsapp':
      default:
        primaryColor = const Color(0xFF25D366);
        platformName = 'WhatsApp';
        platformIcon = Icons.chat_bubble_rounded;
        gradientColors = [const Color(0xFF25D366), const Color(0xFF128C7E)];
        break;
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: widget.onView,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF181824),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Social App Icon / Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      platformIcon,
                      color: style == 'snapchat' ? Colors.black : Colors.white,
                      size: 26,
                    ),
                  ),
                  12.0.width,
                  // Message content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  recruiterName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    platformName,
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'Now',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (price.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Offer: $price',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  8.0.width,
                  // Close button
                  GestureDetector(
                    onTap: _dismiss,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white54,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper manager to safely show booking popups as social media message banners
class BookingAlertManager {
  static OverlayEntry? _currentOverlay;
  static String? _lastShownBookingId;
  static DateTime? _lastShownTime;
  static Map<String, dynamic>? _pendingData;

  /// Main entry point to display the Booking Alert Popup safely from anywhere
  static void show(BuildContext? context, Map<String, dynamic> data) {
    final ctx = context ?? NavigationService.instance.currentContext;
    log('🚨 BookingAlertManager.show called with data: $data, ctx: $ctx, mounted: ${ctx?.mounted}');
    if (ctx == null || !ctx.mounted) {
      log('❌ BookingAlertManager: context is null or not mounted! Storing as pending.');
      _pendingData = data;
      return;
    }

    final bookingId = data['id']?.toString() ??
        data['booking_id']?.toString() ??
        data['bookingId']?.toString();

    // Prevent duplicate popups within 5 seconds for the same booking
    final now = DateTime.now();
    if (_lastShownBookingId != null &&
        _lastShownBookingId == bookingId &&
        bookingId != null &&
        bookingId.isNotEmpty &&
        _lastShownTime != null &&
        now.difference(_lastShownTime!).inSeconds < 5) {
      return;
    }

    if (bookingId != null && bookingId.isNotEmpty) {
      _lastShownBookingId = bookingId;
      _lastShownTime = now;
    }

    // Remove existing overlay if any
    _currentOverlay?.remove();
    _currentOverlay = null;

    // Pick social style (WhatsApp, Snapchat, TikTok)
    final styles = ['whatsapp', 'snapchat', 'tiktok'];
    final style = styles[DateTime.now().millisecond % styles.length];
    data['social_style'] = style;

    _currentOverlay = OverlayEntry(
      builder: (overlayContext) => SocialMessageBanner(
        bookingData: data,
        onDismiss: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
        },
        onView: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
          if (bookingId != null && bookingId.isNotEmpty) {
            NavigationService.instance.push(BookingDetailsView(bookingId: bookingId));
          }
        },
      ),
    );

    Overlay.of(ctx).insert(_currentOverlay!);
  }

  /// Check and show any pending alert if context becomes available
  static void checkPending() {
    if (_pendingData != null) {
      final data = _pendingData!;
      _pendingData = null;
      Future.delayed(const Duration(milliseconds: 500), () {
        show(null, data);
      });
    }
  }

  /// Handles incoming OneSignal Push Notifications (Foreground or Clicked)
  static void handlePushNotification({
    Map<String, dynamic>? additionalData,
    String? title,
    String? body,
  }) {
    final data = <String, dynamic>{};

    if (additionalData != null) {
      data.addAll(additionalData);
    }

    if (title != null && title.isNotEmpty) data['title'] = title;
    if (body != null && body.isNotEmpty && !data.containsKey('title')) {
      data['title'] = body;
    }

    final type = data['type']?.toString().toLowerCase() ?? '';
    final isBookingEvent = type.contains('booking') ||
        (title != null && title.toLowerCase().contains('booking')) ||
        (body != null && body.toLowerCase().contains('booking')) ||
        data.containsKey('booking_id') ||
        data.containsKey('bookingId') ||
        data.containsKey('id') ||
        data.isNotEmpty;

    if (isBookingEvent) {
      show(null, data);
    }
  }
}

/// Backward compatibility class if referenced
class BookingAlertPopup extends StatelessWidget {
  final Map<String, dynamic> bookingData;
  const BookingAlertPopup({super.key, required this.bookingData});

  static void show(BuildContext context, Map<String, dynamic> bookingData) {
    BookingAlertManager.show(context, bookingData);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
