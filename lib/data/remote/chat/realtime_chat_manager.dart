import 'dart:async';
import 'dart:developer';
import 'package:creatify_mobile/data/remote/chat/pusher_service.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';

/// Real-time chat manager that handles all real-time chat functionality
/// following the patterns described in the Medium article
class RealtimeChatManager {
  static final RealtimeChatManager _instance = RealtimeChatManager._internal();
  static RealtimeChatManager get instance => _instance;

  RealtimeChatManager._internal();

  final PusherService _pusherService = PusherService.instance;

  // Stream controllers for different real-time events
  final StreamController<Map<String, dynamic>> _messageController = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _typingController = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _presenceController = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _messageReadController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _messageEditedController =
      StreamController.broadcast();

  // Getters for streams
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get presenceStream => _presenceController.stream;
  Stream<Map<String, dynamic>> get messageReadStream => _messageReadController.stream;
  Stream<Map<String, dynamic>> get messageEditedStream => _messageEditedController.stream;

  bool _isInitialized = false;
  final Set<String> _activeConversations = {};

  /// Initialize the real-time chat manager
  Future<void> initialize() async {
    if (_isInitialized) {
      log('RealtimeChatManager already initialized');
      return;
    }

    try {
      // Initialize Pusher service
      await _pusherService.initialize();

      // Register event callbacks
      _registerEventCallbacks();

      _isInitialized = true;
      log('RealtimeChatManager initialized successfully');
    } catch (e) {
      log('Error initializing RealtimeChatManager: $e');
      rethrow;
    }
  }

  /// Register all event callbacks with the Pusher service
  void _registerEventCallbacks() {
    // New message events - both client and server triggered
    _pusherService.registerEventCallback('message.sent', _handleNewMessage);
    _pusherService.registerEventCallback('new-message', _handleNewMessage);
    _pusherService.registerEventCallback('client-message-sent', _handleNewMessage);

    // Message edited events - both client and server triggered
    _pusherService.registerEventCallback('message.edited', _handleMessageEdited);
    _pusherService.registerEventCallback('client-message-edited', _handleMessageEdited);

    // Message read events - both client and server triggered
    _pusherService.registerEventCallback('messages.read', _handleMessageRead);
    _pusherService.registerEventCallback('client-messages-read', _handleMessageRead);

    // Typing events - both client and server triggered
    _pusherService.registerEventCallback('user.typing', _handleTyping);
    _pusherService.registerEventCallback('typing', _handleTyping);
    _pusherService.registerEventCallback('client-typing', _handleTyping);

    // Presence events - both client and server triggered
    _pusherService.registerEventCallback('user.presence', _handlePresence);
    _pusherService.registerEventCallback('user-presence', _handlePresence);
    _pusherService.registerEventCallback('client-user-presence', _handlePresence);

    log('Event callbacks registered successfully');
  }

  /// Join a conversation (subscribe to all related channels)
  Future<void> joinConversation(String conversationId) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (_activeConversations.contains(conversationId)) {
        log('Already joined conversation: $conversationId');
        return;
      }

      // Subscribe to conversation channels
      await _pusherService.subscribeToConversation(conversationId);

      // Mark as active
      _activeConversations.add(conversationId);

      // Send initial presence
      await _sendInitialPresence(conversationId);

      log('Successfully joined conversation: $conversationId');
    } catch (e) {
      log('Error joining conversation $conversationId: $e');
      rethrow;
    }
  }

  /// Leave a conversation (unsubscribe from all related channels)
  Future<void> leaveConversation(String conversationId) async {
    try {
      if (!_activeConversations.contains(conversationId)) {
        log('Not currently in conversation: $conversationId');
        return;
      }

      // Send offline presence before leaving
      await _sendOfflinePresence(conversationId);

      // Unsubscribe from conversation channels
      await _pusherService.unsubscribeFromConversation(conversationId);

      // Remove from active conversations
      _activeConversations.remove(conversationId);

      log('Successfully left conversation: $conversationId');
    } catch (e) {
      log('Error leaving conversation $conversationId: $e');
    }
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator(String conversationId, bool isTyping) async {
    try {
      await _pusherService.sendTypingIndicator(conversationId, isTyping);
    } catch (e) {
      log('Error sending typing indicator: $e');
    }
  }

  /// Send user presence
  Future<void> sendUserPresence(String conversationId, bool isOnline) async {
    try {
      await _pusherService.sendUserPresence(conversationId, isOnline);
    } catch (e) {
      log('Error sending user presence: $e');
    }
  }

  /// Handle new message events
  void _handleNewMessage(Map<String, dynamic> eventData) {
    try {
      log('New message received: ${eventData['data']}');
      _messageController.add(eventData);
    } catch (e) {
      log('Error handling new message: $e');
    }
  }

  /// Handle message edited events
  void _handleMessageEdited(Map<String, dynamic> eventData) {
    try {
      log('Message edited: ${eventData['messageId']}');
      _messageEditedController.add(eventData);
    } catch (e) {
      log('Error handling message edited: $e');
    }
  }

  /// Handle message read events
  void _handleMessageRead(Map<String, dynamic> eventData) {
    try {
      log('Messages read by: ${eventData['userId']}');
      _messageReadController.add(eventData);
    } catch (e) {
      log('Error handling message read: $e');
    }
  }

  /// Handle typing events
  void _handleTyping(Map<String, dynamic> eventData) {
    try {
      final userId = eventData['userId'];
      final currentUserId = SharedPrefManager.userId;

      // Don't process our own typing events
      if (userId == currentUserId) {
        return;
      }

      log('Typing event from user: $userId');
      _typingController.add(eventData);
    } catch (e) {
      log('Error handling typing event: $e');
    }
  }

  /// Handle presence events
  void _handlePresence(Map<String, dynamic> eventData) {
    try {
      final userId = eventData['userId'];
      final currentUserId = SharedPrefManager.userId;

      // Don't process our own presence events
      if (userId == currentUserId) {
        return;
      }

      log('Presence event from user: $userId');
      _presenceController.add(eventData);
    } catch (e) {
      log('Error handling presence event: $e');
    }
  }

  /// Send initial presence when joining a conversation
  Future<void> _sendInitialPresence(String conversationId) async {
    try {
      await sendUserPresence(conversationId, true);
    } catch (e) {
      log('Error sending initial presence: $e');
    }
  }

  /// Send offline presence when leaving a conversation
  Future<void> _sendOfflinePresence(String conversationId) async {
    try {
      await sendUserPresence(conversationId, false);
    } catch (e) {
      log('Error sending offline presence: $e');
    }
  }

  /// Leave all active conversations
  Future<void> leaveAllConversations() async {
    final activeConversations = List<String>.from(_activeConversations);
    for (final conversationId in activeConversations) {
      await leaveConversation(conversationId);
    }
  }

  /// Disconnect and cleanup
  Future<void> disconnect() async {
    try {
      // Leave all conversations
      await leaveAllConversations();

      // Clear event callbacks
      _pusherService.clearEventCallbacks();

      // Disconnect Pusher
      await _pusherService.disconnect();

      // Close stream controllers
      await _messageController.close();
      await _typingController.close();
      await _presenceController.close();
      await _messageReadController.close();
      await _messageEditedController.close();

      _isInitialized = false;
      log('RealtimeChatManager disconnected');
    } catch (e) {
      log('Error disconnecting RealtimeChatManager: $e');
    }
  }

  /// Get active conversations
  List<String> get activeConversations => _activeConversations.toList();

  /// Check if currently in a conversation
  bool isInConversation(String conversationId) {
    return _activeConversations.contains(conversationId);
  }

  /// Check if initialized
  bool get isInitialized => _isInitialized;
}
