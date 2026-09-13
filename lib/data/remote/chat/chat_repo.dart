import 'package:creatify_mobile/data/models/responses/conversation_dto.dart';
import 'package:creatify_mobile/data/models/responses/conversation_message_dto.dart';
import 'package:creatify_mobile/data/remote/chat/chat_service.dart';

abstract class ChatRepo {
  Future<ConversationDto> createChat(String userId, String bookingId);
  Future<List<ConversationDto>> getChat(String userId);
  Future<List<ConversationMessageDto>> getMessages(String conversationId);
  Future<ConversationMessageDto> sendMessage(
      {required String conversationId, required String message});
  Future<ConversationMessageDto> sendMessageWithAttachment(
      {required String conversationId, required String message, required String filePath});
  Future<String> editMessage({required String messageId, required String message});
  Future<String> markMessagesAsRead(String conversationId);
}

class ChatImpl extends ChatRepo {
  final ChatService _service;

  ChatImpl(this._service);

  @override
  Future<ConversationDto> createChat(String userId, String bookingId) async {
    return await _service.createChat(userId, bookingId);
  }

  @override
  Future<List<ConversationDto>> getChat(String userId) async {
    return await _service.getChat(userId);
  }

  @override
  Future<List<ConversationMessageDto>> getMessages(String conversationId) async {
    return await _service.getMessages(conversationId);
  }

  @override
  Future<String> markMessagesAsRead(String conversationId) async {
    return await _service.markMessagesAsRead(conversationId);
  }

  @override
  Future<ConversationMessageDto> sendMessage(
      {required String conversationId, required String message}) async {
    return await _service.sendMessage(conversationId: conversationId, message: message);
  }

  @override
  Future<ConversationMessageDto> sendMessageWithAttachment(
      {required String conversationId, required String message, required String filePath}) async {
    return await _service.sendMessageWithAttachment(
        conversationId: conversationId, message: message, filePath: filePath);
  }

  @override
  Future<String> editMessage({required String messageId, required String message}) async {
    return await _service.editMessage(messageId: messageId, message: message);
  }
}
