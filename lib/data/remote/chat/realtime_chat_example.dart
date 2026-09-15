import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:creatify_mobile/data/remote/chat/realtime_chat_manager.dart';

/// Example implementation of a real-time chat widget
/// This follows the patterns described in the Medium article:
/// https://medium.com/@syedhasan.cse/implementing-real-time-communication-in-flutter-with-pusher-channels-a-step-by-step-guide-891db932e431
class RealtimeChatExample extends StatefulWidget {
  final String conversationId;
  final String otherUserId;

  const RealtimeChatExample({
    super.key,
    required this.conversationId,
    required this.otherUserId,
  });

  @override
  State<RealtimeChatExample> createState() => _RealtimeChatExampleState();
}

class _RealtimeChatExampleState extends State<RealtimeChatExample> {
  final RealtimeChatManager _chatManager = RealtimeChatManager.instance;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  // Real-time state
  bool _isOtherUserTyping = false;
  bool _isOtherUserOnline = false;
  String _lastSeen = '';

  // Subscriptions
  late StreamSubscription _messageSubscription;
  late StreamSubscription _typingSubscription;
  late StreamSubscription _presenceSubscription;
  late StreamSubscription _messageReadSubscription;

  // Typing timer
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeRealTimeChat();
  }

  /// Initialize real-time chat following the Medium article pattern
  Future<void> _initializeRealTimeChat() async {
    try {
      // Step 1: Initialize the chat manager
      await _chatManager.initialize();

      // Step 2: Join the conversation
      await _chatManager.joinConversation(widget.conversationId);

      // Step 3: Set up event listeners
      _setupEventListeners();

      log('Real-time chat initialized for conversation: ${widget.conversationId}');
    } catch (e) {
      log('Error initializing real-time chat: $e');
    }
  }

  /// Set up all event listeners for real-time events
  void _setupEventListeners() {
    // Listen for new messages
    _messageSubscription = _chatManager.messageStream.listen((eventData) {
      final conversationId = eventData['conversationId'];
      if (conversationId == widget.conversationId) {
        _handleNewMessage(eventData['data']);
      }
    });

    // Listen for typing indicators
    _typingSubscription = _chatManager.typingStream.listen((eventData) {
      final conversationId = eventData['conversationId'];
      final userId = eventData['userId'];

      if (conversationId == widget.conversationId && userId == widget.otherUserId) {
        setState(() {
          _isOtherUserTyping = eventData['isTyping'] ?? false;
        });

        // Clear typing indicator after a delay
        if (_isOtherUserTyping) {
          Timer(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _isOtherUserTyping = false;
              });
            }
          });
        }
      }
    });

    // Listen for presence updates
    _presenceSubscription = _chatManager.presenceStream.listen((eventData) {
      final conversationId = eventData['conversationId'];
      final userId = eventData['userId'];

      if (conversationId == widget.conversationId && userId == widget.otherUserId) {
        setState(() {
          _isOtherUserOnline = eventData['isOnline'] ?? false;
          if (!_isOtherUserOnline && eventData['lastSeen'] != null) {
            _lastSeen = eventData['lastSeen'];
          }
        });
      }
    });

    // Listen for message read receipts
    _messageReadSubscription = _chatManager.messageReadStream.listen((eventData) {
      final conversationId = eventData['conversationId'];
      final userId = eventData['userId'];

      if (conversationId == widget.conversationId && userId == widget.otherUserId) {
        // Update message read status in your local state
        _updateMessageReadStatus(eventData['lastReadMessageId']);
      }
    });
  }

  /// Handle new incoming messages
  void _handleNewMessage(Map<String, dynamic> messageData) {
    setState(() {
      _messages.add({
        'id': messageData['messageId'] ?? messageData['id'],
        'message': messageData['message'] ?? messageData['text'],
        'userId': messageData['userId'],
        'timestamp': messageData['timestamp'] ?? DateTime.now().toIso8601String(),
        'isRead': false,
      });
    });

    // Mark messages as read if the app is active
    _markMessagesAsRead();
  }

  /// Update message read status
  void _updateMessageReadStatus(String lastReadMessageId) {
    setState(() {
      for (int i = 0; i < _messages.length; i++) {
        if (_messages[i]['id'] == lastReadMessageId) {
          // Mark this message and all previous ones as read
          for (int j = 0; j <= i; j++) {
            _messages[j]['isRead'] = true;
          }
          break;
        }
      }
    });
  }

  /// Send a message
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      // Clear the input
      _messageController.clear();

      // Stop typing indicator
      _stopTyping();

      // Add message to local state immediately (optimistic update)
      setState(() {
        _messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'message': message,
          'userId': 'current_user', // Replace with actual current user ID
          'timestamp': DateTime.now().toIso8601String(),
          'isRead': false,
          'isLocal': true, // Flag to indicate this is a local message
        });
      });

      // Here you would typically send the message to your backend API
      // The backend should then broadcast the message via Pusher
      // await _chatService.sendMessage(widget.conversationId, message);
    } catch (e) {
      log('Error sending message: $e');
      // Handle error (remove local message, show error, etc.)
    }
  }

  /// Handle typing indicator
  void _onTextChanged(String text) {
    if (text.isNotEmpty && !_isTyping) {
      _startTyping();
    } else if (text.isEmpty && _isTyping) {
      _stopTyping();
    }

    // Reset typing timer
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 1), () {
      _stopTyping();
    });
  }

  /// Start typing indicator
  Future<void> _startTyping() async {
    if (_isTyping) return;

    _isTyping = true;
    await _chatManager.sendTypingIndicator(widget.conversationId, true);
  }

  /// Stop typing indicator
  Future<void> _stopTyping() async {
    if (!_isTyping) return;

    _isTyping = false;
    await _chatManager.sendTypingIndicator(widget.conversationId, false);
  }

  /// Mark messages as read
  Future<void> _markMessagesAsRead() async {
    // Implementation depends on your backend API
    // This should send a read receipt to your backend
    // which then broadcasts the read event via Pusher
  }

  @override
  void dispose() {
    // Clean up subscriptions
    _messageSubscription.cancel();
    _typingSubscription.cancel();
    _presenceSubscription.cancel();
    _messageReadSubscription.cancel();

    // Clean up timers
    _typingTimer?.cancel();

    // Leave the conversation
    _chatManager.leaveConversation(widget.conversationId);

    // Dispose controllers
    _messageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chat'),
            Text(
              _isOtherUserOnline
                  ? 'Online'
                  : _lastSeen.isNotEmpty
                      ? 'Last seen $_lastSeen'
                      : 'Offline',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isCurrentUser = message['userId'] == 'current_user';

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Align(
                    alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCurrentUser ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message['message'],
                            style: TextStyle(
                              color: isCurrentUser ? Colors.white : Colors.black,
                            ),
                          ),
                          if (isCurrentUser && message['isRead'] == true)
                            const Icon(
                              Icons.done_all,
                              size: 16,
                              color: Colors.white70,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Typing indicator
          if (_isOtherUserTyping)
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'User is typing...',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: _onTextChanged,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Usage example in your app:
/// 
/// ```dart
/// // In your chat screen or conversation view
/// RealtimeChatExample(
///   conversationId: 'conversation_123',
///   otherUserId: 'user_456',
/// )
/// ```
/// 
/// Key features implemented:
/// 1. Real-time message delivery
/// 2. Typing indicators
/// 3. User presence (online/offline status)
/// 4. Message read receipts
/// 5. Proper cleanup and memory management
/// 6. Error handling
/// 7. Optimistic UI updates
