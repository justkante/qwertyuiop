import 'dart:async';
import 'dart:developer';
import 'package:creatify_mobile/core/http/http_service.dart';
import 'package:creatify_mobile/data/models/responses/conversation_dto.dart';
import 'package:creatify_mobile/data/models/responses/conversation_message_dto.dart';
import 'package:creatify_mobile/data/remote/chat/chat_service.dart';
import 'package:creatify_mobile/data/remote/chat/realtime_chat_manager.dart';

/// Enhanced chat service that integrates real-time functionality
/// This service combines traditional HTTP API calls with real-time Pusher events
class EnhancedChatService {
  final ChatService _chatService;
  final RealtimeChatManager _realtimeChatManager = RealtimeChatManager.instance;

  // Stream controllers for enhanced real-time functionality
  final StreamController<ConversationMessageDto> _messageStreamController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _typingStreamController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _presenceStreamController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _messageReadStreamController =
      StreamController.broadcast();

  // Public streams
  Stream<ConversationMessageDto> get messageStream => _messageStreamController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingStreamController.stream;
  Stream<Map<String, dynamic>> get presenceStream => _presenceStreamController.stream;
  Stream<Map<String, dynamic>> get messageReadStream => _messageReadStreamController.stream;

  bool _isInitialized = false;
  StreamSubscription? _realtimeMessageSubscription;
  StreamSubscription? _realtimeTypingSubscription;
  StreamSubscription? _realtimePresenceSubscription;
  StreamSubscription? _realtimeMessageReadSubscription;

  EnhancedChatService({required HttpService networkService})
      : _chatService = ChatService(networkService: networkService);

  /// Initialize the enhanced chat service
  Future<void> initialize() async {
    if (_isInitialized) {
      log('EnhancedChatService already initialized');
      return;
    }

    try {
      // Initialize real-time chat manager
      await _realtimeChatManager.initialize();

      // Set up real-time event forwarding
      _setupRealtimeEventForwarding();

      _isInitialized = true;
      log('EnhancedChatService initialized successfully');
    } catch (e) {
      log('Error initializing EnhancedChatService: $e');
      rethrow;
    }
  }

  /// Set up forwarding of real-time events to our streams
  void _setupRealtimeEventForwarding() {
    // Forward message events
    _realtimeMessageSubscription = _realtimeChatManager.messageStream.listen((eventData) {
      try {
        // Convert real-time event data to ConversationMessageDto
        final messageData = eventData['data'];
        final message = ConversationMessageDto.fromJson(messageData);
        _messageStreamController.add(message);
      } catch (e) {
        log('Error processing real-time message: $e');
      }
    });

    // Forward typing events
    _realtimeTypingSubscription = _realtimeChatManager.typingStream.listen((eventData) {
      _typingStreamController.add(eventData);
    });

    // Forward presence events
    _realtimePresenceSubscription = _realtimeChatManager.presenceStream.listen((eventData) {
      _presenceStreamController.add(eventData);
    });

    // Forward message read events
    _realtimeMessageReadSubscription = _realtimeChatManager.messageReadStream.listen((eventData) {
      _messageReadStreamController.add(eventData);
    });
  }

  /// Join a conversation for real-time updates
  Future<void> joinConversation(String conversationId) async {
    if (!_isInitialized) {
      await initialize();
    }

    await _realtimeChatManager.joinConversation(conversationId);
  }

  /// Leave a conversation
  Future<void> leaveConversation(String conversationId) async {
    await _realtimeChatManager.leaveConversation(conversationId);
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator(String conversationId, bool isTyping) async {
    await _realtimeChatManager.sendTypingIndicator(conversationId, isTyping);
  }

  /// Send user presence
  Future<void> sendUserPresence(String conversationId, bool isOnline) async {
    await _realtimeChatManager.sendUserPresence(conversationId, isOnline);
  }

  // Delegate all existing ChatService methods

  Future<ConversationDto> createChat(String userId, String bookingId) async {
    return await _chatService.createChat(userId, bookingId);
  }

  Future<List<ConversationDto>> getConversationList() async {
    return await _chatService.getChat(''); // Adjust parameter as needed
  }

  Future<List<ConversationMessageDto>> getMessages(String conversationId) async {
    return await _chatService.getMessages(conversationId);
  }

  /// Enhanced send message with real-time optimization
  Future<ConversationMessageDto> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    try {
      // Send message via HTTP API
      final sentMessage = await _chatService.sendMessage(
        conversationId: conversationId,
        message: message,
      );

      // The backend should broadcast this message via Pusher
      // So we don't need to manually trigger real-time events here

      return sentMessage;
    } catch (e) {
      log('Error sending message: $e');
      rethrow;
    }
  }

  /// Enhanced send message with attachment
  Future<ConversationMessageDto> sendMessageWithAttachment({
    required String conversationId,
    required String message,
    required String filePath,
  }) async {
    try {
      final sentMessage = await _chatService.sendMessageWithAttachment(
        conversationId: conversationId,
        message: message,
        filePath: filePath,
      );

      return sentMessage;
    } catch (e) {
      log('Error sending message with attachment: $e');
      rethrow;
    }
  }

  /// Enhanced mark messages as read with real-time notification
  Future<String> markMessagesAsRead(String conversationId) async {
    try {
      final result = await _chatService.markMessagesAsRead(conversationId);

      // The backend should broadcast the read receipt via Pusher
      // So we don't need to manually trigger real-time events here

      return result;
    } catch (e) {
      log('Error marking messages as read: $e');
      rethrow;
    }
  }

  /// Get active conversations
  List<String> get activeConversations => _realtimeChatManager.activeConversations;

  /// Check if currently in a conversation
  bool isInConversation(String conversationId) {
    return _realtimeChatManager.isInConversation(conversationId);
  }

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Dispose and cleanup
  Future<void> dispose() async {
    try {
      // Cancel subscriptions
      await _realtimeMessageSubscription?.cancel();
      await _realtimeTypingSubscription?.cancel();
      await _realtimePresenceSubscription?.cancel();
      await _realtimeMessageReadSubscription?.cancel();

      // Close stream controllers
      await _messageStreamController.close();
      await _typingStreamController.close();
      await _presenceStreamController.close();
      await _messageReadStreamController.close();

      // Disconnect real-time manager
      await _realtimeChatManager.disconnect();

      _isInitialized = false;
      log('EnhancedChatService disposed');
    } catch (e) {
      log('Error disposing EnhancedChatService: $e');
    }
  }
}

/// Usage Example:
/// 
/// ```dart
/// class ChatRepository {
///   final EnhancedChatService _enhancedChatService;
///   
///   ChatRepository(this._enhancedChatService);
///   
///   Future<void> initializeChat() async {
///     await _enhancedChatService.initialize();
///   }
///   
///   Future<void> startConversation(String conversationId) async {
///     // Join conversation for real-time updates
///     await _enhancedChatService.joinConversation(conversationId);
///     
///     // Listen for real-time messages
///     _enhancedChatService.messageStream.listen((message) {
///       // Handle new message
///       print('New message: ${message.message}');
///     });
///     
///     // Listen for typing indicators
///     _enhancedChatService.typingStream.listen((typing) {
///       // Handle typing indicator
///       print('User ${typing['userId']} is typing: ${typing['isTyping']}');
///     });
///   }
///   
///   Future<void> sendMessage(String conversationId, String message) async {
///     await _enhancedChatService.sendMessage(
///       conversationId: conversationId,
///       message: message,
///     );
///   }
///   
///   Future<void> startTyping(String conversationId) async {
///     await _enhancedChatService.sendTypingIndicator(conversationId, true);
///   }
///   
///   Future<void> stopTyping(String conversationId) async {
///     await _enhancedChatService.sendTypingIndicator(conversationId, false);
///   }
/// }
/// ```
