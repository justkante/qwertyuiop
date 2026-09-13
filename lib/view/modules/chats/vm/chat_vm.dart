import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/responses/conversation_dto.dart';
import 'package:creatify_mobile/view/modules/chats/vm/chat_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CreateChatNotifier extends AutoDisposeAsyncNotifier<ConversationDto> {
  Future<void> createNewChat(String userId, String bookingId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(chatRepository).createChat(userId, bookingId));

    if (!state.hasError) {
      // Refresh the conversations list after creating a new chat
      ref.invalidate(fetchConversationsProvider);
    }
  }

  @override
  FutureOr<ConversationDto> build() {
    return ConversationDto();
  }
}

final createChatNotifier = AutoDisposeAsyncNotifierProvider<CreateChatNotifier, ConversationDto>(
  CreateChatNotifier.new,
);

class MarkMessagesAsReadNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> markAsRead(String conversationId) async {
    state = const AsyncValue.loading();

    state =
        await AsyncValue.guard(() => ref.read(chatRepository).markMessagesAsRead(conversationId));

    if (!state.hasError) {
      // Refresh conversations to update unread counts
      ref.invalidate(fetchConversationsProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final markMessagesAsReadNotifier =
    AutoDisposeAsyncNotifierProvider<MarkMessagesAsReadNotifier, String>(
  MarkMessagesAsReadNotifier.new,
);

// Search functionality
class SearchNotifier extends AutoDisposeNotifier<String> {
  void updateSearch(String query) {
    state = query;
    ref.read(searchQueryProvider.notifier).state = query;
  }

  void clearSearch() {
    state = '';
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  String build() {
    return '';
  }
}

final searchNotifier = AutoDisposeNotifierProvider<SearchNotifier, String>(
  SearchNotifier.new,
);
