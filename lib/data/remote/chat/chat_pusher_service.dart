import 'dart:convert';
import 'dart:developer';
import 'pusher_service.dart';
import '../../../core/storage/share_pref.dart';
import '../../../core/http/http_service.dart';

class ChatPusherService {
  static final ChatPusherService _instance = ChatPusherService._internal();
  static ChatPusherService get instance => _instance;

  ChatPusherService._internal();

  final PusherService _pusherService = PusherService.instance;
  final Map<String, Function(dynamic)> _eventHandlers = {};
  String? _currentUserId;
  bool _isInitialized = false;

  /// Get the underlying PusherService instance
  PusherService get pusherService => _pusherService;

  /// Initialize chat-specific Pusher functionality
  Future<void> initialize({HttpService? httpService}) async {
    if (_isInitialized) {
      log('ChatPusherService already initialized, skipping...');
      return;
    }

    try {
      // Pass HttpService to PusherService
      await _pusherService.initialize(httpService: httpService);
      _currentUserId = SharedPrefManager.userId;

      // Register event callbacks
      _registerEventCallbacks();

      _isInitialized = true;
      log('ChatPusherService initialized successfully');
    } catch (e) {
      log('Error initializing ChatPusherService: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Register event callbacks for chat events
  void _registerEventCallbacks() {
    // Register new message callback
    // Register client message sent callback
    _pusherService.registerEventCallback('client-message-sent', (data) {
      final conversationId = data['conversationId'] as String?;
      if (conversationId != null) {
        triggerConversationRefresh(conversationId);
        triggerConversationsRefresh();
      }

      if (_eventHandlers.containsKey('message_sent')) {
        _eventHandlers['message_sent']!(data);
      }
    });

    // Register server-side message sent callback
    _pusherService.registerEventCallback('message.sent', (data) {
      final conversationId = data['conversationId'] as String?;
      if (conversationId != null) {
        triggerConversationRefresh(conversationId);
        triggerConversationsRefresh();
      }

      if (_eventHandlers.containsKey('message_sent')) {
        _eventHandlers['message_sent']!(data);
      }
    });

    // Register legacy new message callback for backward compatibility
    _pusherService.registerEventCallback('new-message', (data) {
      final conversationId = data['conversationId'] as String?;
      if (conversationId != null) {
        triggerConversationRefresh(conversationId);
        triggerConversationsRefresh();
      }

      if (_eventHandlers.containsKey('new_message')) {
        _eventHandlers['new_message']!(data);
      }
    });

    // Register client message edited callback
    _pusherService.registerEventCallback('client-message-edited', (data) {
      final conversationId = data['conversationId'] as String?;
      if (conversationId != null) {
        triggerConversationRefresh(conversationId);
      }

      if (_eventHandlers.containsKey('message_edited')) {
        _eventHandlers['message_edited']!(data);
      }
    });

    // Register server-side message edited callback
    _pusherService.registerEventCallback('message.edited', (data) {
      final conversationId = data['conversationId'] as String?;
      if (conversationId != null) {
        triggerConversationRefresh(conversationId);
      }

      if (_eventHandlers.containsKey('message_edited')) {
        _eventHandlers['message_edited']!(data);
      }
    });

    // Register client messages read callback
    _pusherService.registerEventCallback('client-messages-read', (data) {
      final conversationId = data['conversationId'] as String?;
      if (conversationId != null) {
        triggerConversationRefresh(conversationId);
      }

      if (_eventHandlers.containsKey('messages_read')) {
        _eventHandlers['messages_read']!(data);
      }
    });

    // Register server-side messages read callback
    _pusherService.registerEventCallback('messages.read', (data) {
      final conversationId = data['conversationId'] as String?;
      if (conversationId != null) {
        triggerConversationRefresh(conversationId);
      }

      if (_eventHandlers.containsKey('messages_read')) {
        _eventHandlers['messages_read']!(data);
      }
    });

    // Register user presence callback - listen for client events
    _pusherService.registerEventCallback('client-user-presence', (data) {
      final userId = data['userId'] as String?;
      final isOnline = data['isOnline'] as bool?;

      if (userId != null && isOnline != null) {
        triggerUserStatusUpdate(userId, isOnline);
      }

      if (_eventHandlers.containsKey('user_presence')) {
        _eventHandlers['user_presence']!(data);
      }
    });

    // Register server-side user presence callback (if server also sends this event)
    _pusherService.registerEventCallback('user.presence', (data) {
      final userId = data['userId'] as String?;
      final isOnline = data['isOnline'] as bool?;

      if (userId != null && isOnline != null) {
        triggerUserStatusUpdate(userId, isOnline);
      }

      if (_eventHandlers.containsKey('user_presence')) {
        _eventHandlers['user_presence']!(data);
      }
    });

    // Register legacy user presence callback for backward compatibility
    _pusherService.registerEventCallback('user-presence', (data) {
      final userId = data['userId'] as String?;
      final isOnline = data['isOnline'] as bool?;

      if (userId != null && isOnline != null) {
        triggerUserStatusUpdate(userId, isOnline);
      }

      if (_eventHandlers.containsKey('user_presence')) {
        _eventHandlers['user_presence']!(data);
      }
    });

    // Register typing callback - listen for client events
    _pusherService.registerEventCallback('client-typing', (data) {
      final conversationId = data['conversationId'] as String?;
      final userId = data['userId'] as String?;
      final isTyping = data['isTyping'] as bool?;

      if (conversationId != null && userId != null && isTyping != null) {
        triggerTypingUpdate(conversationId, userId, isTyping);
      }

      if (_eventHandlers.containsKey('user_typing')) {
        _eventHandlers['user_typing']!(data);
      }
    });

    // Register server-side typing callback (if server also sends this event)
    _pusherService.registerEventCallback('user.typing', (data) {
      final conversationId = data['conversationId'] as String?;
      final userId = data['userId'] as String?;
      final isTyping = data['isTyping'] as bool?;

      if (conversationId != null && userId != null && isTyping != null) {
        triggerTypingUpdate(conversationId, userId, isTyping);
      }

      if (_eventHandlers.containsKey('user_typing')) {
        _eventHandlers['user_typing']!(data);
      }
    });

    // Register legacy typing callback for backward compatibility
    _pusherService.registerEventCallback('typing', (data) {
      final conversationId = data['conversationId'] as String?;
      final userId = data['userId'] as String?;
      final isTyping = data['isTyping'] as bool?;

      if (conversationId != null && userId != null && isTyping != null) {
        triggerTypingUpdate(conversationId, userId, isTyping);
      }

      if (_eventHandlers.containsKey('typing')) {
        _eventHandlers['typing']!(data);
      }
    });

    // Register new conversation callback - client event
    _pusherService.registerEventCallback('client-new-conversation', (data) {
      triggerConversationsRefresh();

      if (_eventHandlers.containsKey('new_conversation')) {
        _eventHandlers['new_conversation']!(data);
      }
    });

    // Register new conversation callback - server event
    _pusherService.registerEventCallback('conversation.created', (data) {
      triggerConversationsRefresh();

      if (_eventHandlers.containsKey('new_conversation')) {
        _eventHandlers['new_conversation']!(data);
      }
    });

    // Register legacy new conversation callback for backward compatibility
    _pusherService.registerEventCallback('new-conversation', (data) {
      triggerConversationsRefresh();

      if (_eventHandlers.containsKey('new_conversation')) {
        _eventHandlers['new_conversation']!(data);
      }
    });

    log('Event callbacks registered for chat events');
  }

  /// Subscribe to user's personal channel for new conversations and messages
  Future<void> subscribeToUserChannel() async {
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      _currentUserId = SharedPrefManager.userId;
    }

    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      final channelName = 'private-user.$_currentUserId';
      await _pusherService.subscribeToPrivateChannel(channelName);
      log('Subscribed to user channel: $channelName');
    }
  }

  /// Subscribe to a specific conversation channel
  Future<void> subscribeToConversationChannel(String conversationId) async {
    final channelName = 'private-conversation.$conversationId';
    await _pusherService.subscribeToPrivateChannel(channelName);
    log('Subscribed to conversation channel: $channelName');
  }

  /// Unsubscribe from a conversation channel
  Future<void> unsubscribeFromConversationChannel(String conversationId) async {
    final channelName = 'private-conversation.$conversationId';
    await _pusherService.unsubscribeFromChannel(channelName);
    log('Unsubscribed from conversation channel: $channelName');
  }

  /// Subscribe to typing events for a conversation
  Future<void> subscribeToTypingChannel(String conversationId) async {
    final channelName = 'presence-typing.$conversationId';
    await _pusherService.subscribeToPresenceChannel(channelName);
    log('Subscribed to typing channel: $channelName');
  }

  /// Send typing indicator using new event name
  Future<void> sendTypingIndicator(String conversationId, bool isTyping) async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return;

    final channelName = 'presence-typing.$conversationId';
    const eventName = 'client-typing'; // Client events must start with "client-"

    final data = json.encode({
      'userId': _currentUserId,
      'isTyping': isTyping,
      'timestamp': DateTime.now().toIso8601String(),
    });

    try {
      // First ensure we're subscribed to the typing channel
      if (!_pusherService.getSubscribedChannels().contains(channelName)) {
        await subscribeToTypingChannel(conversationId);
      }

      // Wait for channel to be ready before triggering
      final isReady = await _pusherService.waitForChannelReady(channelName);
      if (!isReady) {
        log('Typing channel $channelName did not become ready within timeout');
        // Still try to trigger - it will be queued if channel is not ready
      }

      await _pusherService.trigger(channelName, eventName, data);
      log('Typing indicator sent: $eventName for conversation $conversationId (isTyping: $isTyping)');
    } catch (e) {
      log('Error sending typing indicator: $e');
    }
  }

  /// Send new message event using new event name
  Future<void> sendMessageSent(String conversationId, Map<String, dynamic> messageData) async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return;

    final channelName = 'private-conversation.$conversationId';
    const eventName = 'client-message-sent'; // Client events must start with "client-"

    final data = json.encode({
      'userId': _currentUserId,
      'timestamp': DateTime.now().toIso8601String(),
      ...messageData,
    });

    try {
      // First ensure we're subscribed to the conversation channel
      if (!_pusherService.getSubscribedChannels().contains(channelName)) {
        await subscribeToConversationChannel(conversationId);
      }

      // Wait for channel to be ready before triggering
      final isReady = await _pusherService.waitForChannelReady(channelName);
      if (!isReady) {
        log('Conversation channel $channelName did not become ready within timeout');
      }

      await _pusherService.trigger(channelName, eventName, data);
      log('Message sent event triggered: $eventName for conversation $conversationId');
    } catch (e) {
      log('Error sending message sent event: $e');
    }
  }

  /// Send message edited event
  Future<void> sendMessageEdited(String conversationId, String messageId, String newMessage) async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return;

    final channelName = 'private-conversation.$conversationId';
    const eventName = 'client-message-edited'; // Client events must start with "client-"

    final data = json.encode({
      'userId': _currentUserId,
      'messageId': messageId,
      'newMessage': newMessage,
      'editedAt': DateTime.now().toIso8601String(),
    });

    try {
      // First ensure we're subscribed to the conversation channel
      if (!_pusherService.getSubscribedChannels().contains(channelName)) {
        await subscribeToConversationChannel(conversationId);
      }

      // Wait for channel to be ready before triggering
      final isReady = await _pusherService.waitForChannelReady(channelName);
      if (!isReady) {
        log('Conversation channel $channelName did not become ready within timeout');
      }

      await _pusherService.trigger(channelName, eventName, data);
      log('Message edited event sent: $eventName for conversation $conversationId');
    } catch (e) {
      log('Error sending message edited event: $e');
    }
  }

  /// Send messages read event
  Future<void> sendMessagesRead(String conversationId, String lastReadMessageId) async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return;

    final channelName = 'private-conversation.$conversationId';
    const eventName = 'client-messages-read'; // Client events must start with "client-"

    final data = json.encode({
      'userId': _currentUserId,
      'lastReadMessageId': lastReadMessageId,
      'readAt': DateTime.now().toIso8601String(),
    });

    try {
      // First ensure we're subscribed to the conversation channel
      if (!_pusherService.getSubscribedChannels().contains(channelName)) {
        await subscribeToConversationChannel(conversationId);
      }

      // Wait for channel to be ready before triggering
      final isReady = await _pusherService.waitForChannelReady(channelName);
      if (!isReady) {
        log('Conversation channel $channelName did not become ready within timeout');
      }

      await _pusherService.trigger(channelName, eventName, data);
      log('Messages read event sent: $eventName for conversation $conversationId');
    } catch (e) {
      log('Error sending messages read event: $e');
    }
  }

  /// Send user presence update using new event name
  Future<void> sendUserPresence(String conversationId, bool isOnline) async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return;

    final channelName = 'presence-typing.$conversationId';
    const eventName = 'client-user-presence'; // Client events must start with "client-"

    final data = json.encode({
      'userId': _currentUserId,
      'isOnline': isOnline,
      'lastSeen': isOnline ? null : DateTime.now().toIso8601String(),
      'timestamp': DateTime.now().toIso8601String(),
    });

    try {
      // First ensure we're subscribed to the typing/presence channel
      if (!_pusherService.getSubscribedChannels().contains(channelName)) {
        await subscribeToTypingChannel(conversationId);
      }

      // Wait for channel to be ready before triggering
      final isReady = await _pusherService.waitForChannelReady(channelName);
      if (!isReady) {
        log('Presence channel $channelName did not become ready within timeout');
      }

      await _pusherService.trigger(channelName, eventName, data);
      log('User presence sent: $eventName for conversation $conversationId (isOnline: $isOnline)');
    } catch (e) {
      log('Error sending user presence: $e');
    }
  }

  /// Send new message notification (legacy method for backward compatibility)
  Future<void> sendNewMessage(String conversationId, Map<String, dynamic> messageData) async {
    // Delegate to the new method
    await sendMessageSent(conversationId, messageData);
  }

  /// Trigger message edited event
  void triggerMessageEdited(String conversationId, String messageId, String newMessage) {
    if (_eventHandlers.containsKey('message_edited_received')) {
      _eventHandlers['message_edited_received']!({
        'conversationId': conversationId,
        'messageId': messageId,
        'newMessage': newMessage,
      });
    }
  }

  /// Trigger messages read event
  void triggerMessagesRead(String conversationId, String userId, String lastReadMessageId) {
    if (_eventHandlers.containsKey('messages_read_received')) {
      _eventHandlers['messages_read_received']!({
        'conversationId': conversationId,
        'userId': userId,
        'lastReadMessageId': lastReadMessageId,
      });
    }
  }

  /// Register event handler for specific event
  void registerEventHandler(String eventName, Function(dynamic) handler) {
    _eventHandlers[eventName] = handler;
  }

  /// Remove event handler
  void removeEventHandler(String eventName) {
    _eventHandlers.remove(eventName);
  }

  /// Trigger conversation refresh - to be connected with Riverpod providers
  void triggerConversationRefresh(String conversationId) {
    if (_eventHandlers.containsKey('refresh_conversation')) {
      _eventHandlers['refresh_conversation']!(conversationId);
    }
  }

  /// Trigger conversations list refresh
  void triggerConversationsRefresh() {
    if (_eventHandlers.containsKey('refresh_conversations')) {
      _eventHandlers['refresh_conversations']!(null);
    }
  }

  /// Trigger typing indicator update
  void triggerTypingUpdate(String conversationId, String userId, bool isTyping) {
    if (_eventHandlers.containsKey('typing_update')) {
      _eventHandlers['typing_update']!({
        'conversationId': conversationId,
        'userId': userId,
        'isTyping': isTyping,
      });
    }
  }

  /// Trigger user status update
  void triggerUserStatusUpdate(String userId, bool isOnline) {
    if (_eventHandlers.containsKey('user_status_update')) {
      _eventHandlers['user_status_update']!({
        'userId': userId,
        'isOnline': isOnline,
      });
    }
  }

  /// Trigger new message received
  void triggerNewMessageReceived(String conversationId, Map<String, dynamic> messageData) {
    if (_eventHandlers.containsKey('new_message_received')) {
      _eventHandlers['new_message_received']!({
        'conversationId': conversationId,
        'messageData': messageData,
      });
    }
  }

  /// Get list of subscribed channels
  List<String> getSubscribedChannels() {
    return _pusherService.getSubscribedChannels();
  }

  /// Cleanup when logging out
  Future<void> cleanup() async {
    try {
      // Unsubscribe from all channels
      final subscribedChannels = _pusherService.getSubscribedChannels();
      for (String channel in subscribedChannels) {
        await _pusherService.unsubscribeFromChannel(channel);
      }

      // Clear event handlers and callbacks
      _eventHandlers.clear();
      _pusherService.clearEventCallbacks();
      _currentUserId = null;

      log('ChatPusherService cleaned up');
    } catch (e) {
      log('Error cleaning up ChatPusherService: $e');
    }
  }

  /// Disconnect completely
  Future<void> disconnect() async {
    await cleanup();
    await _pusherService.disconnect();
  }
}
