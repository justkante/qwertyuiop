import 'package:creatify_mobile/core/http/http_service.dart';
import 'package:creatify_mobile/core/utils/app_url.dart';
import 'package:creatify_mobile/data/models/responses/conversation_dto.dart';
import 'package:creatify_mobile/data/models/responses/conversation_message_dto.dart';
import 'package:dio/dio.dart';

class ChatService {
  final HttpService _networkService;

  ChatService({required HttpService networkService}) : _networkService = networkService;

  Future<ConversationDto> createChat(String userId, String bookingId) async {
    try {
      final response = await _networkService.request(
        endpoints.createChat(userId),
        RequestMethod.get,
        queryParams: bookingId.isNotEmpty ? {"booking_id": bookingId} : null,
      );

      return ConversationDto.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<ConversationDto>> getChat(String userId) async {
    try {
      final response = await _networkService.request(
        endpoints.getConversationList,
        RequestMethod.get,
      );

      return (response.data['data'] as List).map((e) => ConversationDto.fromJson(e)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<ConversationMessageDto>> getMessages(String conversationId) async {
    try {
      final response = await _networkService.request(
        endpoints.getMessages(conversationId),
        RequestMethod.get,
      );

      return (response.data['data'] as List)
          .map((e) => ConversationMessageDto.fromJson(e))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<ConversationMessageDto> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    try {
      final response = await _networkService.request(
        endpoints.sendMessage(conversationId),
        RequestMethod.post,
        data: {
          "message": message,
        },
      );

      return ConversationMessageDto.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<ConversationMessageDto> sendMessageWithAttachment({
    required String conversationId,
    required String message,
    required String filePath,
  }) async {
    try {
      final response = await _networkService.request(
        endpoints.sendMessageWithAttachment(conversationId),
        RequestMethod.post,
        data: FormData.fromMap(
          {
            "file": await MultipartFile.fromFile(filePath),
          },
        ),
      );

      return ConversationMessageDto.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> editMessage({
    required String messageId,
    required String message,
  }) async {
    try {
      await _networkService.request(
        endpoints.editMessage(messageId),
        RequestMethod.post,
        data: {
          "message": message,
        },
      );

      return 'Message Edited';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> markMessagesAsRead(String conversationId) async {
    try {
      final response = await _networkService.request(
        endpoints.markMessagesAsRead(conversationId),
        RequestMethod.post,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }
}
