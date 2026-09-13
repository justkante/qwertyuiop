// To parse this JSON data, do
//
//     final conversationDto = conversationDtoFromJson(jsonString);

import 'dart:convert';

ConversationDto conversationDtoFromJson(String str) => ConversationDto.fromJson(json.decode(str));

String conversationDtoToJson(ConversationDto data) => json.encode(data.toJson());

class ConversationDto {
  final String? id;
  final String? status;
  final bool? isCreator;
  final String? bookingId;
  final OtherUser? otherUser;
  final LastMessage? lastMessage;
  final int? unreadCount;
  final dynamic lastMessageAt;
  final DateTime? createdAt;

  ConversationDto({
    this.id,
    this.status,
    this.isCreator,
    this.bookingId,
    this.otherUser,
    this.lastMessage,
    this.unreadCount,
    this.lastMessageAt,
    this.createdAt,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) => ConversationDto(
        id: json["id"],
        status: json["status"],
        isCreator: json["is_creator"],
        bookingId: json["booking_id"],
        otherUser: json["other_user"] == null ? null : OtherUser.fromJson(json["other_user"]),
        lastMessage:
            json["last_message"] == null ? null : LastMessage.fromJson(json["last_message"]),
        unreadCount: json["unread_count"],
        lastMessageAt: json["last_message_at"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "is_creator": isCreator,
        "booking_id": bookingId,
        "other_user": otherUser?.toJson(),
        "last_message": lastMessage?.toJson(),
        "unread_count": unreadCount,
        "last_message_at": lastMessageAt,
        "created_at": createdAt?.toIso8601String(),
      };
}

class OtherUser {
  final String? id;
  final String? name;
  final String? email;
  final String? avatar;
  final bool? isOnline;
  final dynamic lastSeenAt;

  OtherUser({
    this.id,
    this.name,
    this.email,
    this.avatar,
    this.isOnline,
    this.lastSeenAt,
  });

  factory OtherUser.fromJson(Map<String, dynamic> json) => OtherUser(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        avatar: json["profile_image"],
        isOnline: json["is_online"],
        lastSeenAt: json["last_seen_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "avatar": avatar,
        "is_online": isOnline,
        "last_seen_at": lastSeenAt,
      };
}

class LastMessage {
  final String? id;
  final String? message;
  final String? type;
  final String? senderId;
  final String? senderName;
  final DateTime? createdAt;

  LastMessage({
    this.id,
    this.message,
    this.type,
    this.senderId,
    this.senderName,
    this.createdAt,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
        id: json["id"],
        message: json["message"],
        type: json["type"],
        senderId: json["sender_id"],
        senderName: json["sender_name"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "message": message,
        "type": type,
        "sender_id": senderId,
        "sender_name": senderName,
        "created_at": createdAt?.toIso8601String(),
      };
}
