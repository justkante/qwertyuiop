import 'dart:async';
import 'dart:developer';
import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/responses/conversation_message_dto.dart';
import 'package:creatify_mobile/view/modules/chats/vm/chat_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SendMessageNotifier extends AutoDisposeAsyncNotifier<ConversationMessageDto> {
  Future<void> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    // Set sending state
    ref.read(messageSendingProvider(conversationId).notifier).state = true;

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(chatRepository).sendMessage(
          conversationId: conversationId,
          message: message,
        ));

    // Reset sending state
    ref.read(messageSendingProvider(conversationId).notifier).state = false;

    if (!state.hasError && state.value != null) {
      // Stop typing indicator via Pusher
      try {
        final pusherService = ref.read(chatPusherServiceProvider);
        await pusherService.sendTypingIndicator(conversationId, false);

        // Send message sent event
        await pusherService.sendMessageSent(conversationId, {
          'messageId': state.value!.id,
          'message': state.value!.message,
          'senderId': state.value!.senderId,
          'senderName': state.value!.senderName,
        });
      } catch (e) {
        log('Error sending stop typing indicator or message sent event: $e');
      }

      // Refresh messages and conversations
      ref.invalidate(fetchMessagesProvider(conversationId));
      ref.invalidate(fetchConversationsProvider);
    }
  }

  @override
  FutureOr<ConversationMessageDto> build() {
    return ConversationMessageDto();
  }
}

final sendMessageNotifier =
    AutoDisposeAsyncNotifierProvider<SendMessageNotifier, ConversationMessageDto>(
  SendMessageNotifier.new,
);

class SendMessageWithAttachmentNotifier extends AutoDisposeAsyncNotifier<ConversationMessageDto> {
  Future<void> sendMessageWithAttachment({
    required String conversationId,
    required String message,
    required String filePath,
  }) async {
    // Set sending state
    ref.read(messageSendingProvider(conversationId).notifier).state = true;

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(chatRepository).sendMessageWithAttachment(
          conversationId: conversationId,
          message: message,
          filePath: filePath,
        ));

    // Reset sending state
    ref.read(messageSendingProvider(conversationId).notifier).state = false;

    if (!state.hasError && state.value != null) {
      // Stop typing indicator via Pusher
      try {
        final pusherService = ref.read(chatPusherServiceProvider);
        await pusherService.sendTypingIndicator(conversationId, false);

        // Send message sent event with attachment info
        await pusherService.sendMessageSent(conversationId, {
          'messageId': state.value!.id,
          'message': state.value!.message,
          'senderId': state.value!.senderId,
          'senderName': state.value!.senderName,
          'attachment': state.value!.attachment?.toJson(),
        });
      } catch (e) {
        log('Error sending stop typing indicator or message sent event: $e');
      }

      // Refresh messages and conversations
      ref.invalidate(fetchMessagesProvider(conversationId));
      ref.invalidate(fetchConversationsProvider);
    }
  }

  @override
  FutureOr<ConversationMessageDto> build() {
    return ConversationMessageDto();
  }
}

final sendMessageWithAttachmentNotifier =
    AutoDisposeAsyncNotifierProvider<SendMessageWithAttachmentNotifier, ConversationMessageDto>(
  SendMessageWithAttachmentNotifier.new,
);

// Enhanced typing indicator notifier with Pusher integration
class TypingIndicatorNotifier extends AutoDisposeNotifier<bool> {
  Timer? _typingTimer;

  void startTyping(String conversationId) async {
    state = true;
    ref.read(typingIndicatorProvider(conversationId).notifier).state = true;

    // Send typing indicator via Pusher
    try {
      final pusherService = ref.read(chatPusherServiceProvider);
      await pusherService.sendTypingIndicator(conversationId, true);
    } catch (e) {
      log('Error sending typing indicator: $e');
    }

    // Reset timer
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      stopTyping(conversationId);
    });
  }

  void stopTyping(String conversationId) async {
    state = false;
    ref.read(typingIndicatorProvider(conversationId).notifier).state = false;

    // Send stop typing indicator via Pusher
    try {
      final pusherService = ref.read(chatPusherServiceProvider);
      await pusherService.sendTypingIndicator(conversationId, false);
    } catch (e) {
      log('Error sending stop typing indicator: $e');
    }

    _typingTimer?.cancel();
  }

  @override
  bool build() {
    ref.onDispose(() {
      _typingTimer?.cancel();
    });
    return false;
  }
}

final typingIndicatorNotifier = AutoDisposeNotifierProvider<TypingIndicatorNotifier, bool>(
  TypingIndicatorNotifier.new,
);

// Edit message notifier (placeholder - needs backend implementation)
class EditMessageNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> editMessage({
    required String conversationId,
    required String messageId,
    required String newMessage,
  }) async {
    // // Implement editMessage in ChatRepo when backend endpoint is available
    // state = const AsyncValue.loading();

    // try {
    //   // For now, just send the event via Pusher
    //   // When backend endpoint is available, call repository method first
    //   final pusherService = ref.read(chatPusherServiceProvider);
    //   await pusherService.sendMessageEdited(conversationId, messageId, newMessage);

    //   // Create a placeholder response
    //   final editedMessage = ConversationMessageDto(
    //     id: messageId,
    //     conversationId: conversationId,
    //     message: newMessage,
    //     isEdited: true,
    //     editedAt: DateTime.now().toIso8601String(),
    //   );

    //   state = AsyncValue.data(editedMessage);

    //   // Refresh messages
    //   ref.invalidate(fetchMessagesProvider(conversationId));
    // } catch (e) {
    //   state = AsyncValue.error(e, StackTrace.current);
    //   log('Error editing message: $e');
    // }

    // Set sending state
    ref.read(messageSendingProvider(conversationId).notifier).state = true;

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref.read(chatRepository).editMessage(
            messageId: messageId,
            message: newMessage,
          ),
    );

    // Reset sending state
    ref.read(messageSendingProvider(conversationId).notifier).state = false;

    if (!state.hasError && state.value != null) {
      // Stop typing indicator via Pusher
      try {
        final pusherService = ref.read(chatPusherServiceProvider);
        await pusherService.sendTypingIndicator(conversationId, false);

        // Send message edited event
        await pusherService.sendMessageEdited(
          conversationId,
          messageId,
          newMessage,
        );
      } catch (e) {
        log('Error sending stop typing indicator or message sent event: $e');
      }

      // Refresh messages and conversations
      ref.invalidate(fetchMessagesProvider(conversationId));
      ref.invalidate(fetchConversationsProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final editMessageNotifier = AutoDisposeAsyncNotifierProvider<EditMessageNotifier, String>(
  EditMessageNotifier.new,
);

// Mark messages as read notifier
class MarkMessagesReadNotifier extends AutoDisposeAsyncNotifier<bool> {
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String? lastReadMessageId,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await ref.read(chatRepository).markMessagesAsRead(conversationId);
      return true;
    });

    if (!state.hasError && lastReadMessageId != null) {
      // Send messages read event via Pusher
      try {
        final pusherService = ref.read(chatPusherServiceProvider);
        await pusherService.sendMessagesRead(conversationId, lastReadMessageId);
      } catch (e) {
        log('Error sending messages read event: $e');
      }

      // Update local read status
      ref.read(lastReadMessageProvider(conversationId).notifier).state = lastReadMessageId;

      // Refresh both messages and conversations to update read status and unread counts
      ref.invalidate(fetchMessagesProvider(conversationId));
      ref.invalidate(fetchConversationsProvider);
    }
  }

  @override
  FutureOr<bool> build() {
    return false;
  }
}

final markMessagesReadNotifier = AutoDisposeAsyncNotifierProvider<MarkMessagesReadNotifier, bool>(
  MarkMessagesReadNotifier.new,
);

// User presence notifier
class UserPresenceNotifier extends AutoDisposeAsyncNotifier<bool> {
  Future<void> updatePresence({
    required String conversationId,
    required bool isOnline,
  }) async {
    state = AsyncValue.data(isOnline);

    // Send user presence event via Pusher
    try {
      final pusherService = ref.read(chatPusherServiceProvider);
      await pusherService.sendUserPresence(conversationId, isOnline);
    } catch (e) {
      log('Error sending user presence event: $e');
    }
  }

  @override
  FutureOr<bool> build() {
    return true; // Assume user is online by default
  }
}

final userPresenceNotifier = AutoDisposeAsyncNotifierProvider<UserPresenceNotifier, bool>(
  UserPresenceNotifier.new,
);
