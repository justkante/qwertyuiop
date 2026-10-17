import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/http/dio_http_service.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/responses/conversation_dto.dart';
import 'package:creatify_mobile/data/models/responses/conversation_message_dto.dart';
import 'package:creatify_mobile/data/remote/chat/chat_pusher_service.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/booking_alert_popup.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/jobs/vm/job_controller.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/get_transactions_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:developer';

// Pusher service provider
final chatPusherServiceProvider = Provider<ChatPusherService>((ref) {
  return ChatPusherService.instance;
});

// Provider for initializing Pusher connection
final pusherInitializationProvider = FutureProvider<bool>((ref) async {
  try {
    final pusherService = ref.read(chatPusherServiceProvider);
    // Watch user state so that whenever user data is loaded or changes, we subscribe to the correct channel
    final user = ref.watch(userControllerProvider);
    final userId = user.id ?? SharedPrefManager.userId;

    // Create NetworkService instance for Pusher authorization
    final httpService = NetworkService();

    await pusherService.initialize(httpService: httpService);
    
    // Subscribe to user channel to receive new conversations and user-specific events
    if (userId.isNotEmpty) {
      await pusherService.subscribeToUserChannel(userId: userId);
    } else {
      log('pusherInitializationProvider: User ID not available yet, channel subscription deferred');
    }

    // Set up event handlers for real-time updates
    pusherService.registerEventHandler('refresh_conversations', (data) {
      // Invalidate conversations to refetch
      ref.invalidate(fetchConversationsProvider);
    });

    pusherService.registerEventHandler('refresh_conversation', (conversationId) {
      if (conversationId != null) {
        // Invalidate specific conversation messages
        ref.invalidate(fetchMessagesProvider(conversationId));
      }
    });

    // Handle new message events
    pusherService.registerEventHandler('message_sent', (data) {
      if (data != null && data is Map<String, dynamic>) {
        final conversationId = data['conversationId'] as String?;
        if (conversationId != null) {
          // Invalidate messages for this conversation
          ref.invalidate(fetchMessagesProvider(conversationId));
          ref.invalidate(fetchConversationsProvider);
        }
      }
    });

    // Handle message edited events
    pusherService.registerEventHandler('message_edited', (data) {
      if (data != null && data is Map<String, dynamic>) {
        final conversationId = data['conversationId'] as String?;
        if (conversationId != null) {
          // Invalidate messages for this conversation
          ref.invalidate(fetchMessagesProvider(conversationId));
        }
      }
    });

    // Handle messages read events
    pusherService.registerEventHandler('messages_read', (data) {
      if (data != null && data is Map<String, dynamic>) {
        final conversationId = data['conversationId'] as String?;
        if (conversationId != null) {
          // Update read status for messages
          ref.invalidate(fetchMessagesProvider(conversationId));
          // Also invalidate conversations to update unread count and last message status
          ref.invalidate(fetchConversationsProvider);
        }
      }
    });

    // Handle new conversation events (for receiver)
    pusherService.registerEventHandler('new_conversation', (data) {
      // Invalidate conversations to fetch the newly created conversation
      ref.invalidate(fetchConversationsProvider);
    });

    // Handle comprehensive creator & recruiter booking, job, payment, subscription, and notification events
    final refreshBookingsAndNotifications = (data) {
      ref.invalidate(fetchReceivedBookingsProvider);
      ref.invalidate(fetchSentBookingsProvider);
      ref.invalidate(fetchPendingReviewsProvider);

      if (data is Map) {
        final bookingId = data['id']?.toString() ?? data['booking_id']?.toString() ?? data['bookingId']?.toString();
        if (bookingId != null && bookingId.isNotEmpty) {
          ref.invalidate(fetchBookingDetailsProvider(bookingId));
          ref.invalidate(fetchBookingDeliverablesProvider(bookingId));
        }
      }
      
      // Show social media message banner instantly before notification page updates
      final mapData = data is Map<String, dynamic>
          ? data
          : (data is Map ? Map<String, dynamic>.from(data) : {'title': data?.toString() ?? 'New Booking Request'});
      BookingAlertManager.show(null, mapData);

      // Delay invalidating notifications slightly so popup appears before it hits notification page
      Future.delayed(const Duration(milliseconds: 2000), () {
        ref.invalidate(fetchNotificationsProvider);
      });
    };

    final refreshJobsAndApplications = (data) {
      ref.invalidate(jobControllerProvider);
      Future.delayed(const Duration(milliseconds: 1000), () {
        ref.invalidate(fetchNotificationsProvider);
      });
    };

    final refreshWalletAndTransactions = (data) {
      ref.invalidate(getTransactionsProvider);
      Future.delayed(const Duration(milliseconds: 1000), () {
        ref.invalidate(fetchNotificationsProvider);
      });
    };

    final refreshSubscription = (data) {
      ref.invalidate(fetchMySubscriptionProvider);
      Future.delayed(const Duration(milliseconds: 1000), () {
        ref.invalidate(fetchNotificationsProvider);
      });
    };

    final refreshNotificationsOnly = (data) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        ref.invalidate(fetchNotificationsProvider);
      });

      final context = NavigationService.instance.currentContext;
      if (context != null && context.mounted) {
        String message = 'New notification received';
        if (data is Map) {
          message = data['message']?.toString() ?? data['title']?.toString() ?? message;
        } else if (data != null) {
          message = data.toString();
        }
        ToastDialog.showSuccess(message, context);
      }
    };

    final bookingKeys = [
      'booking_created', 'new_booking', 'booking', 'booking.created', 'booking-created',
      'booking_confirmed', 'booking_paid', 'booking_accepted', 'booking.confirmed', 'booking-confirmed',
      'booking_cancelled', 'booking_declined',
      'deliverable_approved', 'booking_deliverable_approved',
      'revision_requested', 'booking_revision_requested',
      'deliverable_submitted', 'booking_deliverable_submitted',
      'BookingCreated', 'NewBooking', 'BookingConfirmed', 'BookingPaid', 'BookingAccepted'
    ];
    for (var key in bookingKeys) {
      pusherService.registerEventHandler(key, refreshBookingsAndNotifications);
    }

    final jobKeys = [
      'job_application_created', 'new_application', 'application_submitted', 'job_application',
      'job_application_updated', 'application_status_updated',
      'job_expired', 'job_closed'
    ];
    for (var key in jobKeys) {
      pusherService.registerEventHandler(key, refreshJobsAndApplications);
    }

    final walletKeys = [
      'payout_status', 'withdrawal_status', 'wallet_updated', 'payout', 'transaction_updated',
      'payment_confirmed', 'escrow_funded', 'payment_success'
    ];
    for (var key in walletKeys) {
      pusherService.registerEventHandler(key, refreshWalletAndTransactions);
    }

    final subKeys = ['subscription_updated', 'subscription_renewed'];
    for (var key in subKeys) {
      pusherService.registerEventHandler(key, refreshSubscription);
    }

    final notifKeys = ['notification_received', 'new_notification', 'notification'];
    for (var key in notifKeys) {
      pusherService.registerEventHandler(key, refreshNotificationsOnly);
    }

    // Handle typing updates
    pusherService.registerEventHandler('typing_update', (data) {
      if (data != null && data is Map<String, dynamic>) {
        final conversationId = data['conversationId'] as String?;
        final userId = data['userId'] as String?;
        final isTyping = data['isTyping'] as bool?;

        if (conversationId != null && userId != null && isTyping != null) {
          // Update typing indicator state
          ref.read(typingUsersProvider(conversationId).notifier).updateTypingUser(userId, isTyping);
        }
      }
    });

    // Handle user presence updates
    pusherService.registerEventHandler('user_presence', (data) {
      if (data != null && data is Map<String, dynamic>) {
        final userId = data['userId'] as String?;
        final isOnline = data['isOnline'] as bool?;
        final lastSeen = data['lastSeen'] as String?;

        if (userId != null && isOnline != null) {
          // Update user online status across the app
          ref.read(userPresenceProvider(userId).notifier).state = isOnline;

          // Update last seen time if provided
          if (lastSeen != null) {
            ref.read(userLastSeenProvider(userId).notifier).state = lastSeen;
          }

          // Always invalidate conversations to update the UI with new online status
          ref.invalidate(fetchConversationsProvider);
        }
      }
    });

    return true;
  } catch (e) {
    log('Error initializing Pusher: $e');
    return false;
  }
});

// Provider to fetch all conversations/chats
final fetchConversationsProvider = FutureProvider.autoDispose<List<ConversationDto>>((ref) async {
  final userId = SharedPrefManager.userId;
  return await ref.watch(chatRepository).getChat(userId);
});

// Provider to fetch messages for a specific conversation
final fetchMessagesProvider = FutureProvider.autoDispose
    .family<List<ConversationMessageDto>, String>((ref, conversationId) async {
  // Subscribe to conversation channel when fetching messages only if not already subscribed
  final pusherService = ref.read(chatPusherServiceProvider);

  // Get currently subscribed channels to avoid duplicate subscriptions
  final subscribedChannels = pusherService.getSubscribedChannels();
  final conversationChannel = 'private-conversation.$conversationId';
  final typingChannel = 'presence-typing.$conversationId';

  try {
    // Only subscribe if not already subscribed
    if (!subscribedChannels.contains(conversationChannel)) {
      await pusherService.subscribeToConversationChannel(conversationId);
    }

    if (!subscribedChannels.contains(typingChannel)) {
      await pusherService.subscribeToTypingChannel(conversationId);
    }
  } catch (e) {
    log('Error subscribing to conversation channels: $e');
    // Don't rethrow - allow fetching messages even if Pusher subscription fails
  }

  return await ref.watch(chatRepository).getMessages(conversationId);
});

// Provider to create a new chat
// final createChatProvider =
//     FutureProvider.autoDispose.family<ConversationDto, (String, String)>((ref, (userId, bookingId)) async {
//   return await ref.watch(chatRepository).createChat(userId, bookingId);
// });

// State provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');
final chatFilterProvider = StateProvider<String>((ref) => 'All');

// Filtered conversations based on search query and chat filter
final filteredConversationsProvider =
    Provider.autoDispose<AsyncValue<List<ConversationDto>>>((ref) {
  final conversationsAsync = ref.watch(fetchConversationsProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final filter = ref.watch(chatFilterProvider);

  return conversationsAsync.when(
    data: (conversations) {
      var filtered = conversations;

      if (filter == 'Unread') {
        filtered = filtered.where((c) => (c.unreadCount ?? 0) > 0).toList();
      } else if (filter == 'Read') {
        filtered = filtered.where((c) => (c.unreadCount ?? 0) == 0).toList();
      }

      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((conversation) {
          final name = conversation.otherUser?.name?.toLowerCase() ?? '';
          final email = conversation.otherUser?.email?.toLowerCase() ?? '';
          return name.contains(searchQuery) || email.contains(searchQuery);
        }).toList();
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Typing users state notifier
class TypingUsersNotifier extends StateNotifier<Set<String>> {
  TypingUsersNotifier() : super({});

  void updateTypingUser(String userId, bool isTyping) {
    if (isTyping) {
      state = {...state, userId};
    } else {
      state = state.where((id) => id != userId).toSet();
    }
  }

  void clearTypingUsers() {
    state = {};
  }
}

// Provider for typing users in a conversation
final typingUsersProvider =
    StateNotifierProvider.family<TypingUsersNotifier, Set<String>, String>((ref, conversationId) {
  return TypingUsersNotifier();
});

// Provider to check if anyone is typing in a conversation
final isAnyoneTypingProvider = Provider.family<bool, String>((ref, conversationId) {
  final typingUsers = ref.watch(typingUsersProvider(conversationId));
  final currentUserId = SharedPrefManager.userId;

  // Remove current user from typing users and check if anyone else is typing
  final othersTyping = typingUsers.where((userId) => userId != currentUserId).toSet();
  return othersTyping.isNotEmpty;
});

// Provider for typing indicator text
final typingIndicatorTextProvider = Provider.family<String, String>((ref, conversationId) {
  final typingUsers = ref.watch(typingUsersProvider(conversationId));
  final currentUserId = SharedPrefManager.userId;

  // Remove current user from typing users
  final othersTyping = typingUsers.where((userId) => userId != currentUserId).toList();

  if (othersTyping.isEmpty) return '';

  if (othersTyping.length == 1) {
    return '${othersTyping.first} is typing...';
  } else if (othersTyping.length == 2) {
    return '${othersTyping[0]} and ${othersTyping[1]} are typing...';
  } else {
    return '${othersTyping.length} people are typing...';
  }
});

// Provider for typing indicators (backward compatibility)
final typingIndicatorProvider = StateProvider.family<bool, String>((ref, conversationId) => false);

// Provider for message sending status
final messageSendingProvider = StateProvider.family<bool, String>((ref, conversationId) => false);

// Provider for user presence status
final userPresenceProvider = StateProvider.family<bool, String>((ref, userId) => false);

// Provider for user last seen time
final userLastSeenProvider = StateProvider.family<String?, String>((ref, userId) => null);

// Provider for message read status
final messageReadStatusProvider =
    StateProvider.family<Map<String, DateTime?>, String>((ref, conversationId) => {});

// Provider to track last read message ID for conversations
final lastReadMessageProvider =
    StateProvider.family<String?, String>((ref, conversationId) => null);

// Provider to track pending messages (messages being sent)
final pendingMessagesProvider = StateProvider.family<List<ConversationMessageDto>, String>(
  (ref, conversationId) => [],
);

// Provider to track sent messages (successfully sent but not yet in main list)
final sentMessagesProvider = StateProvider.family<List<ConversationMessageDto>, String>(
  (ref, conversationId) => [],
);

/// Helper function to format last seen time
String formatLastSeen(String? lastSeenAt) {
  if (lastSeenAt == null || lastSeenAt.isEmpty) {
    return 'Offline';
  }

  try {
    final lastSeenDateTime = DateTime.parse(lastSeenAt);
    final now = DateTime.now();
    final difference = now.difference(lastSeenDateTime);

    if (difference.inSeconds < 60) {
      return 'Last seen just now';
    } else if (difference.inMinutes < 60) {
      return 'Last seen ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Last seen ${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return 'Last seen ${difference.inDays}d ago';
    } else {
      // Show the date for times longer than a week
      return 'Last seen ${lastSeenDateTime.day}/${lastSeenDateTime.month}/${lastSeenDateTime.year}';
    }
  } catch (e) {
    log('Error parsing last seen time: $e');
    return 'Offline';
  }
}

// Provider to calculate total unread count across all conversations
final totalUnreadCountProvider = Provider.autoDispose<AsyncValue<int>>((ref) {
  final conversationsAsync = ref.watch(fetchConversationsProvider);

  return conversationsAsync.when(
    data: (conversations) {
      final totalUnread = conversations.fold<int>(0, (sum, conversation) {
        return sum + (conversation.unreadCount ?? 0);
      });
      return AsyncValue.data(totalUnread);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
