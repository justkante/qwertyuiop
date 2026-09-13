import 'dart:developer';
import 'dart:convert';
import 'dart:async';
import 'package:creatify_mobile/core/env/env.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/core/utils/app_url.dart';
import 'package:creatify_mobile/core/http/http_service.dart';
import 'package:creatify_mobile/main.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();
  static PusherService get instance => _instance;

  PusherService._internal();

  PusherChannelsFlutter? _pusher;
  bool _isInitialized = false;
  final Map<String, String> _subscribedChannels = {};
  final Map<String, bool> _channelSubscriptionStatus = {};
  final Map<String, List<PusherEvent>> _pendingEvents = {};
  final Map<String, Function(Map<String, dynamic>)> _eventCallbacks = {};
  HttpService? _httpService; // Store HttpService instance

  // Connection monitoring
  Timer? _connectionHeartbeatTimer;
  bool _isConnected = false;
  final Duration _heartbeatInterval = const Duration(seconds: 30);

  PusherChannelsFlutter? get pusher => _pusher;
  bool get isInitialized => _isInitialized;
  bool get isConnected => _isConnected;

  /// Set the HttpService instance for authorization
  void setHttpService(HttpService httpService) {
    _httpService = httpService;
    log('HttpService set for Pusher authorization');
  }

  /// Initialize Pusher with your app credentials
  Future<void> initialize({HttpService? httpService}) async {
    if (_isInitialized) {
      log('Pusher already initialized, skipping...');
      return;
    }

    // Set HttpService if provided
    if (httpService != null) {
      _httpService = httpService;
    }

    try {
      _pusher = PusherChannelsFlutter.getInstance();

      await _pusher!.init(
        apiKey: environmentNotifier.value == 'dev' ? Env.pusherAppKey : Env.prodPusherAppKey,
        cluster: Env.pusherCluster,
        onConnectionStateChange: _onConnectionStateChange,
        onError: _onError,
        onSubscriptionSucceeded: _onSubscriptionSucceeded,
        onEvent: _onEvent,
        onSubscriptionError: _onSubscriptionError,
        onDecryptionFailure: _onDecryptionFailure,
        onMemberAdded: _onMemberAdded,
        onMemberRemoved: _onMemberRemoved,
        onSubscriptionCount: _onSubscriptionCount,
        onAuthorizer: _onAuthorizer,
        logToConsole: true,
      );

      await _pusher!.connect();
      _isInitialized = true;
      _isConnected = true;
      _startConnectionHeartbeat();
      log('Pusher initialized successfully using onAuthorizer callback for authentication');
    } catch (e) {
      log('Error initializing Pusher: $e');
      _isInitialized = false; // Reset on error
      rethrow;
    }
  }

  /// Start periodic connection heartbeat check
  void _startConnectionHeartbeat() {
    _stopConnectionHeartbeat();

    _connectionHeartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      _checkConnectionHealth();
    });

    log('Connection heartbeat started');
  }

  /// Stop the connection heartbeat
  void _stopConnectionHeartbeat() {
    _connectionHeartbeatTimer?.cancel();
    _connectionHeartbeatTimer = null;
  }

  /// Check if connection is healthy and attempt recovery if needed
  Future<void> _checkConnectionHealth() async {
    try {
      if (!_isInitialized || _pusher == null) {
        return;
      }

      // If connection was lost, attempt to reconnect
      if (!_isConnected) {
        log('Connection lost detected, attempting to reconnect...');
        await reconnect();
      }
    } catch (e) {
      log('Error in connection health check: $e');
    }
  }

  /// Reconnect to Pusher
  Future<void> reconnect() async {
    try {
      log('Attempting to reconnect to Pusher...');

      if (_pusher == null) {
        log('Pusher instance is null, reinitializing...');
        await initialize(httpService: _httpService);
        return;
      }

      // Disconnect and reconnect
      try {
        await _pusher!.disconnect();
      } catch (e) {
        log('Error disconnecting during reconnect: $e');
      }

      // Small delay before reconnecting
      await Future.delayed(const Duration(milliseconds: 500));

      await _pusher!.connect();
      _isConnected = true;
      log('Successfully reconnected to Pusher');

      // Re-subscribe to all channels
      await _resubscribeToAllChannels();
    } catch (e) {
      log('Error reconnecting to Pusher: $e');
      _isConnected = false;

      // Retry reconnection after a delay
      Future.delayed(const Duration(seconds: 5), () {
        if (_isInitialized && !_isConnected) {
          reconnect();
        }
      });
    }
  }

  /// Re-subscribe to all previously subscribed channels
  Future<void> _resubscribeToAllChannels() async {
    try {
      final channels = _subscribedChannels.keys.toList();
      log('Re-subscribing to ${channels.length} channels after reconnection');

      for (final channelName in channels) {
        try {
          // Reset subscription status
          _channelSubscriptionStatus[channelName] = false;
          await _pusher!.subscribe(channelName: channelName);
          log('Re-subscribed to channel: $channelName');
        } catch (e) {
          log('Error re-subscribing to channel $channelName: $e');
        }
      }
    } catch (e) {
      log('Error re-subscribing to channels: $e');
    }
  }

  /// Subscribe to a channel
  Future<void> subscribeToChannel(String channelName) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (_subscribedChannels.containsKey(channelName)) {
        log('Already subscribed to channel: $channelName');
        return;
      }

      // Mark as subscribed BEFORE subscribing to prevent race conditions
      _subscribedChannels[channelName] = channelName;
      _channelSubscriptionStatus[channelName] = false;

      await _pusher!.subscribe(channelName: channelName);
      log('Subscribed to channel: $channelName');
    } catch (e) {
      log('Error subscribing to channel $channelName: $e');
      // Remove from subscribed channels on error
      _subscribedChannels.remove(channelName);
      _channelSubscriptionStatus.remove(channelName);
      rethrow;
    }
  }

  /// Unsubscribe from a channel
  Future<void> unsubscribeFromChannel(String channelName) async {
    try {
      if (_subscribedChannels.containsKey(channelName)) {
        await _pusher!.unsubscribe(channelName: channelName);
        _subscribedChannels.remove(channelName);
        _channelSubscriptionStatus.remove(channelName);
        _pendingEvents.remove(channelName);
        log('Unsubscribed from channel: $channelName');
      }
    } catch (e) {
      log('Error unsubscribing from channel $channelName: $e');
    }
  }

  /// Subscribe to a private channel (requires authentication)
  Future<void> subscribeToPrivateChannel(String channelName,
      {String? authEndpoint, Map<String, String>? authHeaders}) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (_subscribedChannels.containsKey(channelName)) {
        log('Already subscribed to private channel: $channelName');
        return;
      }

      // Mark as subscribed BEFORE subscribing to prevent race conditions
      _subscribedChannels[channelName] = channelName;
      _channelSubscriptionStatus[channelName] = false;

      await _pusher!
          .subscribe(
        channelName: channelName,
      )
          .then((value) async {
        log('Subscribed to private channel: ${value.channelName}');
      });
    } catch (e) {
      log('Error subscribing to private channel $channelName: $e');
      // Remove from subscribed channels on error
      _subscribedChannels.remove(channelName);
      _channelSubscriptionStatus.remove(channelName);
      rethrow;
    }
  }

  /// Subscribe to presence channel
  Future<void> subscribeToPresenceChannel(String channelName) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (_subscribedChannels.containsKey(channelName)) {
        log('Already subscribed to presence channel: $channelName');
        return;
      }

      // Mark as subscribed BEFORE subscribing to prevent race conditions
      _subscribedChannels[channelName] = channelName;
      _channelSubscriptionStatus[channelName] = false;

      await _pusher!.subscribe(channelName: channelName);
      log('Subscribed to presence channel: $channelName');
    } catch (e) {
      log('Error subscribing to presence channel $channelName: $e');
      // Remove from subscribed channels on error
      _subscribedChannels.remove(channelName);
      _channelSubscriptionStatus.remove(channelName);
      rethrow;
    }
  }

  /// Trigger an event on a channel (client events for private/presence channels)
  Future<void> trigger(String channelName, String eventName, String data) async {
    try {
      final event = PusherEvent(
        channelName: channelName,
        eventName: eventName,
        data: data,
      );

      // Check if channel is fully subscribed
      if (_channelSubscriptionStatus[channelName] == true) {
        await _pusher!.trigger(event);
        log('Triggered event $eventName on channel $channelName');
      } else if (_subscribedChannels.containsKey(channelName)) {
        // Channel is subscribed but not yet ready, queue the event
        log('Channel $channelName not ready, queueing event $eventName');
        _pendingEvents.putIfAbsent(channelName, () => []).add(event);

        // Wait for subscription to complete and retry
        final isReady = await waitForChannelReady(channelName, timeout: const Duration(seconds: 3));
        if (isReady) {
          await _retryTriggerEvent(channelName, event);
        } else {
          log('Channel $channelName did not become ready, event $eventName will remain queued');
        }
      } else {
        // Channel is not subscribed at all
        throw Exception('Channel $channelName is not subscribed. Subscribe to the channel first.');
      }
    } catch (e) {
      log('Error triggering event $eventName on channel $channelName: $e');
      rethrow;
    }
  }

  /// Retry triggering an event
  Future<void> _retryTriggerEvent(String channelName, PusherEvent event) async {
    try {
      if (_channelSubscriptionStatus[channelName] == true) {
        await _pusher!.trigger(event);
        log('Successfully triggered queued event ${event.eventName} on channel $channelName');

        // Remove from pending events
        _pendingEvents[channelName]
            ?.removeWhere((e) => e.eventName == event.eventName && e.data == event.data);
        if (_pendingEvents[channelName]?.isEmpty == true) {
          _pendingEvents.remove(channelName);
        }
      } else {
        log('Channel $channelName still not ready for event ${event.eventName}');
      }
    } catch (e) {
      log('Error retrying event ${event.eventName} on channel $channelName: $e');
    }
  }

  /// Process pending events for a channel
  Future<void> _processPendingEvents(String channelName) async {
    final events = _pendingEvents[channelName];
    if (events != null && events.isNotEmpty) {
      log('Processing ${events.length} pending events for channel $channelName');

      for (final event in List.from(events)) {
        try {
          await _pusher!.trigger(event);
          log('Successfully triggered pending event ${event.eventName} on channel $channelName');
        } catch (e) {
          log('Error triggering pending event ${event.eventName} on channel $channelName: $e');
        }
      }

      _pendingEvents.remove(channelName);
    }
  }

  /// Disconnect from Pusher
  Future<void> disconnect() async {
    try {
      _stopConnectionHeartbeat();

      // Unsubscribe from all channels
      for (String channelName in _subscribedChannels.keys) {
        await unsubscribeFromChannel(channelName);
      }

      await _pusher?.disconnect();
      _isInitialized = false;
      _isConnected = false;
      _channelSubscriptionStatus.clear();
      _pendingEvents.clear();
      _eventCallbacks.clear();
      log('Pusher disconnected');
    } catch (e) {
      log('Error disconnecting Pusher: $e');
    }
  }

  /// Get list of subscribed channels
  List<String> getSubscribedChannels() {
    return _subscribedChannels.keys.toList();
  }

  /// Check if a channel is ready for triggering events
  bool isChannelReady(String channelName) {
    return _channelSubscriptionStatus[channelName] == true;
  }

  /// Wait for a channel to be ready with timeout
  Future<bool> waitForChannelReady(String channelName,
      {Duration timeout = const Duration(seconds: 5)}) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      if (_channelSubscriptionStatus[channelName] == true) {
        return true;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return false;
  }

  /// Register event callback
  void registerEventCallback(String eventName, Function(Map<String, dynamic>) callback) {
    _eventCallbacks[eventName] = callback;
    log('Registered callback for event: $eventName');
  }

  /// Remove event callback
  void removeEventCallback(String eventName) {
    _eventCallbacks.remove(eventName);
    log('Removed callback for event: $eventName');
  }

  /// Clear all event callbacks
  void clearEventCallbacks() {
    _eventCallbacks.clear();
    log('Cleared all event callbacks');
  }

  /// Send typing indicator to a conversation
  Future<void> sendTypingIndicator(String conversationId, bool isTyping) async {
    try {
      final channelName = 'presence-typing.$conversationId';
      final userId = SharedPrefManager.userId;

      if (userId.isEmpty) {
        log('Cannot send typing indicator: User ID not available');
        return;
      }

      final eventData = {
        'userId': userId,
        'isTyping': isTyping,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await trigger(channelName, 'client-typing', json.encode(eventData));
      log('Sent typing indicator: $isTyping for conversation: $conversationId');
    } catch (e) {
      log('Error sending typing indicator: $e');
    }
  }

  /// Send user presence update
  Future<void> sendUserPresence(String conversationId, bool isOnline) async {
    try {
      final channelName = 'private-conversation.$conversationId';
      final userId = SharedPrefManager.userId;

      if (userId.isEmpty) {
        log('Cannot send presence: User ID not available');
        return;
      }

      final eventData = {
        'userId': userId,
        'isOnline': isOnline,
        'timestamp': DateTime.now().toIso8601String(),
        'lastSeen': isOnline ? null : DateTime.now().toIso8601String(),
      };

      await trigger(channelName, 'client-user-presence', json.encode(eventData));
      log('Sent user presence: $isOnline for conversation: $conversationId');
    } catch (e) {
      log('Error sending user presence: $e');
    }
  }

  /// Subscribe to conversation events (messages, typing, presence)
  Future<void> subscribeToConversation(String conversationId) async {
    try {
      // Subscribe to main conversation channel for messages
      await subscribeToPrivateChannel('private-conversation.$conversationId');

      // Subscribe to typing indicators channel
      await subscribeToPresenceChannel('presence-typing.$conversationId');

      log('Subscribed to all channels for conversation: $conversationId');
    } catch (e) {
      log('Error subscribing to conversation channels: $e');
      rethrow;
    }
  }

  /// Unsubscribe from conversation events
  Future<void> unsubscribeFromConversation(String conversationId) async {
    try {
      await unsubscribeFromChannel('private-conversation.$conversationId');
      await unsubscribeFromChannel('presence-typing.$conversationId');

      log('Unsubscribed from all channels for conversation: $conversationId');
    } catch (e) {
      log('Error unsubscribing from conversation channels: $e');
    }
  }

  // Event handlers
  void _onConnectionStateChange(String currentState, String previousState) {
    log('Pusher connection state changed from $previousState to $currentState');

    // Track connection state
    _isConnected = currentState.toLowerCase() == 'connected';

    if (_isConnected) {
      log('Pusher is now CONNECTED');
      // Start heartbeat if not running
      if (_connectionHeartbeatTimer == null) {
        _startConnectionHeartbeat();
      }
    } else if (currentState.toLowerCase() == 'disconnected' ||
        currentState.toLowerCase() == 'failed' ||
        currentState.toLowerCase() == 'unavailable') {
      log('Pusher connection lost: $currentState');
      _isConnected = false;
      // Schedule reconnection attempt
      _scheduleReconnection();
    }
  }

  /// Schedule a reconnection attempt
  void _scheduleReconnection() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_isInitialized && !_isConnected) {
        log('Executing scheduled reconnection...');
        reconnect();
      }
    });
  }

  void _onError(String message, int? code, dynamic e) {
    log('Pusher error: $message, code: $code, exception: $e');
  }

  void _onSubscriptionSucceeded(String channelName, dynamic data) {
    log('Successfully subscribed to channel: $channelName');
    _channelSubscriptionStatus[channelName] = true;

    // Process any pending events for this channel
    _processPendingEvents(channelName);
  }

  void _onEvent(PusherEvent event) {
    log('Received event: ${event.eventName} on channel: ${event.channelName}');
    log('Event data: ${event.data}');

    // Handle specific events
    switch (event.eventName) {
      case 'message.sent':
      case 'new-message':
      case 'client-message-sent':
        _handleNewMessageEvent(event);
        break;
      case 'message.edited':
      case 'client-message-edited':
        _handleMessageEditedEvent(event);
        break;
      case 'messages.read':
      case 'client-messages-read':
        _handleMessagesReadEvent(event);
        break;
      case 'user.typing':
      case 'typing':
      case 'client-typing':
        _handleTypingEvent(event);
        break;
      case 'user.presence':
      case 'client-user-presence':
        _handleUserPresenceEvent(event);
        break;
      default:
        log('Unhandled event type: ${event.eventName}');
    }
  }

  /// Handle new message events
  void _handleNewMessageEvent(PusherEvent event) {
    try {
      final data = json.decode(event.data);
      log('New message received: ${data['messageId'] ?? 'Unknown ID'} from user ${data['userId'] ?? 'Unknown'}');

      // Extract conversation ID from channel name
      final channelName = event.channelName;
      final conversationId = channelName.replaceFirst('private-conversation.', '');

      // Trigger callback if registered
      if (_eventCallbacks.containsKey('message.sent')) {
        _eventCallbacks['message.sent']!({
          'conversationId': conversationId,
          'data': data,
        });
      }
      if (_eventCallbacks.containsKey('new-message')) {
        _eventCallbacks['new-message']!({
          'conversationId': conversationId,
          'data': data,
        });
      }
    } catch (e) {
      log('Error handling new message event: $e');
    }
  }

  /// Handle message edited events
  void _handleMessageEditedEvent(PusherEvent event) {
    try {
      final data = json.decode(event.data);
      log('Message edited: ${data['messageId'] ?? 'Unknown ID'} by user ${data['userId'] ?? 'Unknown'}');

      // Extract conversation ID from channel name
      final channelName = event.channelName;
      final conversationId = channelName.replaceFirst('private-conversation.', '');

      // Trigger callback if registered
      if (_eventCallbacks.containsKey('message.edited')) {
        _eventCallbacks['message.edited']!({
          'conversationId': conversationId,
          'messageId': data['messageId'],
          'newMessage': data['newMessage'],
          'editedAt': data['editedAt'],
          'userId': data['userId'],
        });
      }
    } catch (e) {
      log('Error handling message edited event: $e');
    }
  }

  /// Handle messages read events
  void _handleMessagesReadEvent(PusherEvent event) {
    try {
      final data = json.decode(event.data);
      log('Messages read by user: ${data['userId'] ?? 'Unknown'} up to message: ${data['lastReadMessageId'] ?? 'Unknown'}');

      // Extract conversation ID from channel name
      final channelName = event.channelName;
      final conversationId = channelName.replaceFirst('private-conversation.', '');

      // Trigger callback if registered
      if (_eventCallbacks.containsKey('messages.read')) {
        _eventCallbacks['messages.read']!({
          'conversationId': conversationId,
          'userId': data['userId'],
          'lastReadMessageId': data['lastReadMessageId'],
          'readAt': data['readAt'],
        });
      }
    } catch (e) {
      log('Error handling messages read event: $e');
    }
  }

  /// Handle user presence events
  void _handleUserPresenceEvent(PusherEvent event) {
    try {
      final data = json.decode(event.data);
      log('User presence update: ${data['userId']} is ${data['isOnline'] ? 'online' : 'offline'}');

      // Extract conversation ID from channel name if it's a conversation-specific presence
      String? conversationId;
      final channelName = event.channelName;

      if (channelName.startsWith('presence-typing.')) {
        conversationId = channelName.replaceFirst('presence-typing.', '');
      } else if (channelName.startsWith('private-conversation.')) {
        conversationId = channelName.replaceFirst('private-conversation.', '');
      }

      // Trigger callback if registered
      if (_eventCallbacks.containsKey('user.presence')) {
        _eventCallbacks['user.presence']!({
          'conversationId': conversationId,
          'userId': data['userId'],
          'isOnline': data['isOnline'],
          'lastSeen': data['lastSeen'],
          'timestamp': data['timestamp'],
        });
      }
      if (_eventCallbacks.containsKey('user-presence')) {
        _eventCallbacks['user-presence']!({
          'conversationId': conversationId,
          'userId': data['userId'],
          'isOnline': data['isOnline'],
          'timestamp': data['timestamp'],
        });
      }
    } catch (e) {
      log('Error handling user presence event: $e');
    }
  }

  /// Handle typing events
  void _handleTypingEvent(PusherEvent event) {
    try {
      final data = json.decode(event.data);
      log('Typing indicator: ${data['userId']} is ${data['isTyping'] ? 'typing' : 'not typing'}');

      // Extract conversation ID from channel name
      final channelName = event.channelName;
      final conversationId = channelName.replaceFirst('presence-typing.', '');

      // Trigger callback if registered
      if (_eventCallbacks.containsKey('user.typing')) {
        _eventCallbacks['user.typing']!({
          'conversationId': conversationId,
          'userId': data['userId'],
          'isTyping': data['isTyping'],
          'timestamp': data['timestamp'],
        });
      }
      if (_eventCallbacks.containsKey('typing')) {
        _eventCallbacks['typing']!({
          'conversationId': conversationId,
          'userId': data['userId'],
          'isTyping': data['isTyping'],
          'timestamp': data['timestamp'],
        });
      }
    } catch (e) {
      log('Error handling typing event: $e');
    }
  }

  void _onSubscriptionError(String message, dynamic e) {
    log('Subscription error: $message, exception: $e');

    // Try to extract channel name from error message if possible
    // This is a fallback to mark channels as failed if subscription fails
    final regex = RegExp(r'channel (\S+)');
    final match = regex.firstMatch(message);
    if (match != null) {
      final channelName = match.group(1);
      if (channelName != null) {
        _channelSubscriptionStatus[channelName] = false;
        log('Marked channel $channelName as failed due to subscription error');
      }
    }
  }

  void _onDecryptionFailure(String event, String reason) {
    log('Decryption failure for event: $event, reason: $reason');
  }

  void _onMemberAdded(String channelName, PusherMember member) {
    log('Member added to channel $channelName: ${member.userId}');
  }

  void _onMemberRemoved(String channelName, PusherMember member) {
    log('Member removed from channel $channelName: ${member.userId}');
  }

  void _onSubscriptionCount(String channelName, int subscriptionCount) {
    log('Subscription count for channel $channelName: $subscriptionCount');
  }

  /// Handle authorization for private/presence channels
  dynamic _onAuthorizer(String channelName, String socketId, dynamic options) async {
    try {
      log('=== PUSHER AUTHORIZATION START ===');
      log('Channel: $channelName');
      log('Socket ID: $socketId');

      final userId = SharedPrefManager.userId;
      log('User ID: $userId');

      if (userId.isEmpty) {
        log('ERROR: No user ID available');
        // Return null instead of throwing to avoid FlutterError cast crash
        return null;
      }

      // Check if HttpService is available
      if (_httpService == null) {
        log('ERROR: HttpService not set');
        // Return null instead of throwing to avoid FlutterError cast crash
        return null;
      }

      final authData = {
        'socket_id': socketId,
        'channel_name': channelName,
      };

      log('Making authorization request to: ${endpoints.pusherAuthorisationUrl}');
      log('Request data: $authData');

      // Make authorization request to backend using HttpService
      // The TokenInterceptor will automatically add the Authorization header
      final response = await _httpService!.request(
        endpoints.pusherAuthorisationUrl,
        RequestMethod.post,
        data: authData,
      );

      log('Authorization response status: ${response.statusCode}');
      log('Authorization response data type: ${response.data.runtimeType}');
      log('Authorization response data: ${response.data}');

      if (response.statusCode == 200) {
        // Handle both Map and String responses
        Map<String, dynamic> responseData;
        if (response.data is Map<String, dynamic>) {
          responseData = response.data as Map<String, dynamic>;
        } else if (response.data is String) {
          try {
            responseData = json.decode(response.data as String) as Map<String, dynamic>;
          } catch (e) {
            log('ERROR: Failed to parse string response as JSON: $e');
            // Return null instead of throwing to avoid FlutterError cast crash
            return null;
          }
        } else {
          log('ERROR: Unexpected response data type: ${response.data.runtimeType}');
          // Return null instead of throwing to avoid FlutterError cast crash
          return null;
        }

        log('✓ Authorization successful');
        log('Auth response keys: ${responseData.keys.toList()}');

        // Verify required fields are present
        if (!responseData.containsKey('auth')) {
          log('WARNING: Response missing "auth" field');
          // Return null if auth field is missing to avoid crash
          return null;
        }

        // For presence channels, add user info if not already present
        if (channelName.startsWith('presence-') && !responseData.containsKey('channel_data')) {
          log('Adding channel_data for presence channel');
          responseData['channel_data'] = json.encode({
            'user_id': userId,
            'user_info': {
              'id': userId,
              'name': userId, // You can customize this with actual user name
            }
          });
        }

        log('=== PUSHER AUTHORIZATION SUCCESS ===');
        return responseData;
      } else {
        log('✗ Authorization failed');
        log('Status code: ${response.statusCode}');
        log('Response body: ${response.data}');
        log('=== PUSHER AUTHORIZATION FAILED ===');
        // Return null instead of throwing to avoid FlutterError cast crash
        return null;
      }
    } catch (e, stackTrace) {
      log('✗✗✗ ERROR in channel authorization ✗✗✗');
      log('Error: $e');
      log('Stack trace: $stackTrace');
      log('=== PUSHER AUTHORIZATION ERROR ===');

      // CRITICAL FIX: Return null instead of rethrowing to prevent FlutterError
      // from being passed to iOS, which causes SIGABRT crash when trying to cast
      // FlutterError to NSDictionary
      return null;
    }
  }
}
