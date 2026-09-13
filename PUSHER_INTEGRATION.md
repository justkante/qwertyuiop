# Integrating Pusher Channels for Real-Time Chat in Flutter

This guide shows how to implement real-time chat using Pusher Channels with Riverpod state management and Dio for HTTP requests.

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  pusher_channels_flutter: ^2.2.1
  flutter_riverpod: ^2.4.0
  dio: ^5.4.0
```

## Project Structure

```
lib/
├── providers/
│   ├── pusher_provider.dart
│   └── chat_provider.dart
├── models/
│   └── chat_message.dart
├── services/
│   └── pusher_service.dart
└── screens/
    └── chat_screen.dart
```

## 1. Setup Pusher Service

Create `lib/services/pusher_service.dart`:

```dart
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:dio/dio.dart';

class PusherService {
  final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  final Dio dio;
  final String baseUrl;
  
  PusherService({
    required this.dio,
    required this.baseUrl,
  });

  Future<void> initialize({
    required String apiKey,
    required String cluster,
    required String authToken,
  }) async {
    try {
      await pusher.init(
        apiKey: apiKey,
        cluster: cluster,
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: onEvent,
        onSubscriptionError: onSubscriptionError,
        onDecryptionFailure: onDecryptionFailure,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
        onAuthorizer: onAuthorizer,
      );

      await pusher.connect();
    } catch (e) {
      print('Error initializing Pusher: $e');
      rethrow;
    }
  }

  // Authorization for private/presence channels
  dynamic onAuthorizer(
    String channelName,
    String socketId,
    dynamic options,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/broadcasting/auth',
        data: {
          'socket_id': socketId,
          'channel_name': channelName,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            // Add your auth token here
            'Authorization': 'Bearer YOUR_AUTH_TOKEN',
          },
        ),
      );

      return response.data;
    } catch (e) {
      print('Authorization error: $e');
      rethrow;
    }
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    print('Connection: $currentState');
  }

  void onError(String message, int? code, dynamic e) {
    print('onError: $message code: $code exception: $e');
  }

  void onEvent(PusherEvent event) {
    print('onEvent: ${event.eventName} ${event.data}');
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    print('onSubscriptionSucceeded: $channelName data: $data');
  }

  void onSubscriptionError(String message, dynamic e) {
    print('onSubscriptionError: $message Exception: $e');
  }

  void onDecryptionFailure(String event, String reason) {
    print('onDecryptionFailure: $event reason: $reason');
  }

  void onMemberAdded(String channelName, PusherMember member) {
    print('onMemberAdded: $channelName member: $member');
  }

  void onMemberRemoved(String channelName, PusherMember member) {
    print('onMemberRemoved: $channelName member: $member');
  }

  Future<void> subscribeToChannel(String channelName) async {
    await pusher.subscribe(channelName: channelName);
  }

  Future<void> unsubscribeFromChannel(String channelName) async {
    await pusher.unsubscribe(channelName: channelName);
  }

  Future<void> disconnect() async {
    await pusher.disconnect();
  }

  // Trigger client events (only for presence/private channels)
  Future<void> triggerClientEvent({
    required String channelName,
    required String eventName,
    required String data,
  }) async {
    await pusher.trigger(
      PusherEvent(
        channelName: channelName,
        eventName: eventName,
        data: data,
      ),
    );
  }
}
```

## 2. Create Message Model

Create `lib/models/chat_message.dart`:

```dart
import 'dart:convert';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isEdited;
  final List<String> readBy;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isEdited = false,
    this.readBy = const [],
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? '',
      senderName: json['sender_name'] ?? '',
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isEdited: json['is_edited'] ?? false,
      readBy: List<String>.from(json['read_by'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_name': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'is_edited': isEdited,
      'read_by': readBy,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isEdited,
    List<String>? readBy,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isEdited: isEdited ?? this.isEdited,
      readBy: readBy ?? this.readBy,
    );
  }
}

class UserPresence {
  final String userId;
  final bool isOnline;
  final DateTime? lastSeen;

  UserPresence({
    required this.userId,
    required this.isOnline,
    this.lastSeen,
  });

  factory UserPresence.fromJson(Map<String, dynamic> json) {
    return UserPresence(
      userId: json['user_id'] ?? '',
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] != null 
          ? DateTime.parse(json['last_seen']) 
          : null,
    );
  }
}

class TypingIndicator {
  final String userId;
  final String userName;
  final bool isTyping;

  TypingIndicator({
    required this.userId,
    required this.userName,
    required this.isTyping,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      isTyping: json['is_typing'] ?? false,
    );
  }
}
```

## 3. Setup Providers

Create `lib/providers/pusher_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/pusher_service.dart';

// Dio provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
  
  // Add interceptors if needed
  return dio;
});

// Pusher Service provider
final pusherServiceProvider = Provider<PusherService>((ref) {
  final dio = ref.watch(dioProvider);
  return PusherService(
    dio: dio,
    baseUrl: 'YOUR_BASE_URL', // Replace with your actual base URL
  );
});

// Initialize Pusher
final pusherInitProvider = FutureProvider<void>((ref) async {
  final pusherService = ref.watch(pusherServiceProvider);
  
  await pusherService.initialize(
    apiKey: 'YOUR_PUSHER_API_KEY',
    cluster: 'YOUR_PUSHER_CLUSTER', // e.g., 'us2', 'eu', 'ap1'
    authToken: 'YOUR_AUTH_TOKEN',
  );
});
```

Create `lib/providers/chat_provider.dart`:

```dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../models/chat_message.dart';
import '../services/pusher_service.dart';
import 'pusher_provider.dart';

// Chat state
class ChatState {
  final List<ChatMessage> messages;
  final Map<String, UserPresence> userPresences;
  final Map<String, TypingIndicator> typingUsers;
  final bool isConnected;

  ChatState({
    this.messages = const [],
    this.userPresences = const {},
    this.typingUsers = const {},
    this.isConnected = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    Map<String, UserPresence>? userPresences,
    Map<String, TypingIndicator>? typingUsers,
    bool? isConnected,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      userPresences: userPresences ?? this.userPresences,
      typingUsers: typingUsers ?? this.typingUsers,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

// Chat Notifier
class ChatNotifier extends StateNotifier<ChatState> {
  final PusherService pusherService;
  final String chatId;
  StreamSubscription? _eventSubscription;

  ChatNotifier({
    required this.pusherService,
    required this.chatId,
  }) : super(ChatState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final pusher = pusherService.pusher;
    final channelName = 'private-chat.$chatId';

    // Subscribe to the channel
    await pusherService.subscribeToChannel(channelName);

    // Listen to events
    pusher.onEvent = _handlePusherEvent;
    
    state = state.copyWith(isConnected: true);
  }

  void _handlePusherEvent(PusherEvent event) {
    if (!event.channelName.contains(chatId)) return;

    try {
      final data = jsonDecode(event.data);

      switch (event.eventName) {
        case 'message.sent':
          _handleMessageSent(data);
          break;
        case 'message.edited':
          _handleMessageEdited(data);
          break;
        case 'messages.read':
          _handleMessagesRead(data);
          break;
        case 'user.typing':
          _handleUserTyping(data);
          break;
        case 'user.presence':
          _handleUserPresence(data);
          break;
      }
    } catch (e) {
      print('Error handling event: $e');
    }
  }

  void _handleMessageSent(Map<String, dynamic> data) {
    final message = ChatMessage.fromJson(data);
    state = state.copyWith(
      messages: [...state.messages, message],
    );
  }

  void _handleMessageEdited(Map<String, dynamic> data) {
    final editedMessage = ChatMessage.fromJson(data);
    final updatedMessages = state.messages.map((msg) {
      return msg.id == editedMessage.id ? editedMessage : msg;
    }).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  void _handleMessagesRead(Map<String, dynamic> data) {
    final userId = data['user_id'] as String;
    final messageIds = List<String>.from(data['message_ids'] ?? []);

    final updatedMessages = state.messages.map((msg) {
      if (messageIds.contains(msg.id)) {
        return msg.copyWith(
          readBy: [...msg.readBy, userId],
        );
      }
      return msg;
    }).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  void _handleUserTyping(Map<String, dynamic> data) {
    final indicator = TypingIndicator.fromJson(data);
    final updatedTyping = Map<String, TypingIndicator>.from(state.typingUsers);

    if (indicator.isTyping) {
      updatedTyping[indicator.userId] = indicator;
    } else {
      updatedTyping.remove(indicator.userId);
    }

    state = state.copyWith(typingUsers: updatedTyping);

    // Auto-remove typing indicator after 3 seconds
    if (indicator.isTyping) {
      Future.delayed(const Duration(seconds: 3), () {
        final current = Map<String, TypingIndicator>.from(state.typingUsers);
        current.remove(indicator.userId);
        state = state.copyWith(typingUsers: current);
      });
    }
  }

  void _handleUserPresence(Map<String, dynamic> data) {
    final presence = UserPresence.fromJson(data);
    final updatedPresences = Map<String, UserPresence>.from(state.userPresences);
    updatedPresences[presence.userId] = presence;

    state = state.copyWith(userPresences: updatedPresences);
  }

  // Send typing indicator
  Future<void> sendTypingIndicator(String userId, String userName, bool isTyping) async {
    await pusherService.triggerClientEvent(
      channelName: 'private-chat.$chatId',
      eventName: 'client-user.typing',
      data: jsonEncode({
        'user_id': userId,
        'user_name': userName,
        'is_typing': isTyping,
      }),
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    pusherService.unsubscribeFromChannel('private-chat.$chatId');
    super.dispose();
  }
}

// Chat provider
final chatProvider = StateNotifierProvider.family<ChatNotifier, ChatState, String>(
  (ref, chatId) {
    final pusherService = ref.watch(pusherServiceProvider);
    return ChatNotifier(
      pusherService: pusherService,
      chatId: chatId,
    );
  },
);
```

## 4. Create Chat Screen

Create `lib/screens/chat_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../providers/pusher_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String currentUserId;
  final String currentUserName;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.currentUserId,
    required this.currentUserName,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final isCurrentlyTyping = _messageController.text.isNotEmpty;
    if (isCurrentlyTyping != _isTyping) {
      setState(() => _isTyping = isCurrentlyTyping);
      
      ref.read(chatProvider(widget.chatId).notifier).sendTypingIndicator(
        widget.currentUserId,
        widget.currentUserName,
        isCurrentlyTyping,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pusherInit = ref.watch(pusherInitProvider);
    final chatState = ref.watch(chatProvider(widget.chatId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chat'),
            if (chatState.isConnected)
              const Text(
                'Connected',
                style: TextStyle(fontSize: 12, color: Colors.green),
              ),
          ],
        ),
      ),
      body: pusherInit.when(
        data: (_) => Column(
          children: [
            // Messages list
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: chatState.messages.length,
                itemBuilder: (context, index) {
                  final message = chatState.messages[chatState.messages.length - 1 - index];
                  final isMe = message.senderId == widget.currentUserId;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Text(
                              message.senderName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          Text(
                            message.content,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(message.timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              if (message.isEdited)
                                Text(
                                  ' (edited)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isMe ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              if (isMe && message.readBy.isNotEmpty)
                                const Icon(
                                  Icons.done_all,
                                  size: 12,
                                  color: Colors.blue,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Typing indicator
            if (chatState.typingUsers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _getTypingText(chatState.typingUsers.values.toList()),
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),

            // Message input
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      // Send message via your API
                      // The backend will broadcast via Pusher
                      _messageController.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getTypingText(List<dynamic> typingUsers) {
    if (typingUsers.isEmpty) return '';
    if (typingUsers.length == 1) {
      return '${typingUsers[0].userName} is typing...';
    }
    return '${typingUsers.length} people are typing...';
  }
}
```

## 5. Usage in Main App

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      home: ChatScreen(
        chatId: 'chat_123',
        currentUserId: 'user_456',
        currentUserName: 'John Doe',
      ),
    );
  }
}
```

## Key Features Implemented

✅ **message.sent** - Receives new messages in real-time  
✅ **message.edited** - Updates edited messages  
✅ **messages.read** - Shows read receipts  
✅ **user.typing** - Displays typing indicators  
✅ **user.presence** - Tracks online/offline status  
✅ **Authorization** - Handles private channel authentication  
✅ **Riverpod state management** - Clean, reactive state  
✅ **Dio integration** - HTTP requests for auth

## Important Notes

1. **Replace placeholders**: Update `YOUR_BASE_URL`, `YOUR_PUSHER_API_KEY`, and `YOUR_PUSHER_CLUSTER` with your actual values
2. **Auth token**: Pass the user's auth token dynamically in the `onAuthorizer` method
3. **Backend**: Your backend should broadcast these events when actions occur (sending messages, editing, etc.)
4. **Channel naming**: Private channels must start with `private-` and presence channels with `presence-`
5. **Client events**: Only work on private/presence channels and must start with `client-`

## Testing

To test the integration:
1. Initialize Pusher in your app
2. Subscribe to a chat channel
3. Trigger events from your backend
4. Verify events are received and UI updates accordingly

Let me know if you need help with any specific part!