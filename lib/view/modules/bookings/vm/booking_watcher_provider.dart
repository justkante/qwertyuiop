import 'dart:async';
import 'dart:developer';

import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/booking_alert_popup.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final bookingWatcherProvider = Provider<BookingWatcher>((ref) {
  final watcher = BookingWatcher(ref);
  watcher.start();
  ref.onDispose(() => watcher.stop());
  return watcher;
});

class BookingWatcher {
  final Ref ref;
  Timer? _pollingTimer;
  final Set<String> _knownBookingIds = {};
  bool _initialized = false;

  BookingWatcher(this.ref);

  void start() {
    _pollingTimer?.cancel();

    // Poll received & sent bookings every 5 seconds for fast cross-user syncing
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await checkNewBookings();
    });

    // Initial check
    checkNewBookings();
  }

  void stop() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> checkNewBookings() async {
    try {
      final user = ref.read(userControllerProvider);
      if (user.id == null || user.id!.isEmpty) return;

      // Invalidate both received and sent caches to force fresh network request
      ref.invalidate(fetchReceivedBookingsProvider);
      ref.invalidate(fetchSentBookingsProvider);

      final receivedAsync = await ref.read(fetchReceivedBookingsProvider.future);
      final sentAsync = await ref.read(fetchSentBookingsProvider.future);

      final allBookings = [...receivedAsync, ...sentAsync];
      if (allBookings.isEmpty) {
        _initialized = true;
        return;
      }

      final currentIds = <String>{};

      for (final booking in allBookings) {
        final id = booking.id;
        if (id == null || id.isEmpty) continue;
        currentIds.add(id);

        // Invalidate specific booking details provider to keep detail screens auto-refreshed
        ref.invalidate(fetchBookingDetailsProvider(id));
        ref.invalidate(fetchBookingDeliverablesProvider(id));

        // If watcher is already initialized and finds a new booking ID (only for received)
        if (_initialized && !_knownBookingIds.contains(id)) {
          final isReceived = receivedAsync.any((b) => b.id == id);
          if (isReceived) {
            log('🔍 BookingWatcher detected new received booking: $id');

            final price = (booking.finalPrice != null && booking.finalPrice!.isNotEmpty)
                ? booking.finalPrice
                : ((booking.offeredPrice != null && booking.offeredPrice!.isNotEmpty)
                    ? booking.offeredPrice
                    : '');

            BookingAlertManager.show(null, {
              'id': id,
              'booking_id': id,
              'title': booking.jobDescription ?? 'New Booking Request',
              'price': price,
            });
          }
        }
      }

      _knownBookingIds.addAll(currentIds);
      _initialized = true;
    } catch (e) {
      log('BookingWatcher check failed: $e');
    }
  }
}
