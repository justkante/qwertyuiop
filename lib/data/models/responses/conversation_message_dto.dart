// To parse this JSON data, do
//
//     final conversationMessageDto = conversationMessageDtoFromJson(jsonString);

import 'dart:convert';

List<ConversationMessageDto> conversationMessageDtoFromJson(String str) =>
    List<ConversationMessageDto>.from(
        json.decode(str).map((x) => ConversationMessageDto.fromJson(x)));

String conversationMessageDtoToJson(List<ConversationMessageDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ConversationMessageDto {
  final String? id;
  final String? conversationId;
  final String? senderId;
  final String? senderName;
  final String? message;
  final String? type;
  final bool? isEdited;
  final dynamic editedAt;
  final dynamic readAt;
  final bool? isEditable;
  final DateTime? createdAt;
  final Attachment? attachment;

  ConversationMessageDto({
    this.id,
    this.conversationId,
    this.senderId,
    this.senderName,
    this.message,
    this.type,
    this.isEdited,
    this.editedAt,
    this.readAt,
    this.isEditable,
    this.createdAt,
    this.attachment,
  });

  ConversationMessageDto copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? message,
    String? type,
    bool? isEdited,
    dynamic editedAt,
    dynamic readAt,
    bool? isEditable,
    DateTime? createdAt,
    Attachment? attachment,
  }) =>
      ConversationMessageDto(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        senderId: senderId ?? this.senderId,
        senderName: senderName ?? this.senderName,
        message: message ?? this.message,
        type: type ?? this.type,
        isEdited: isEdited ?? this.isEdited,
        editedAt: editedAt ?? this.editedAt,
        readAt: readAt ?? this.readAt,
        isEditable: isEditable ?? this.isEditable,
        createdAt: createdAt ?? this.createdAt,
        attachment: attachment ?? this.attachment,
      );

  factory ConversationMessageDto.fromJson(Map<String, dynamic> json) => ConversationMessageDto(
        id: json["id"],
        conversationId: json["conversation_id"],
        senderId: json["sender_id"],
        senderName: json["sender_name"],
        message: json["message"],
        type: json["type"],
        isEdited: json["is_edited"],
        editedAt: json["edited_at"],
        readAt: json["read_at"],
        isEditable: json["is_editable"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        attachment: json["attachment"] == null ? null : Attachment.fromJson(json["attachment"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "conversation_id": conversationId,
        "sender_id": senderId,
        "sender_name": senderName,
        "message": message,
        "type": type,
        "is_edited": isEdited,
        "edited_at": editedAt,
        "read_at": readAt,
        "is_editable": isEditable,
        "created_at": createdAt?.toIso8601String(),
        "attachment": attachment?.toJson(),
      };
}

class Attachment {
  final String? id;
  final String? fileName;
  final String? filePath;
  final int? fileSize;
  final double? fileSizeMb;
  final String? fileType;
  final String? mimeType;

  Attachment({
    this.id,
    this.fileName,
    this.filePath,
    this.fileSize,
    this.fileSizeMb,
    this.fileType,
    this.mimeType,
  });

  Attachment copyWith({
    String? id,
    String? fileName,
    String? filePath,
    int? fileSize,
    double? fileSizeMb,
    String? fileType,
    String? mimeType,
  }) =>
      Attachment(
        id: id ?? this.id,
        fileName: fileName ?? this.fileName,
        filePath: filePath ?? this.filePath,
        fileSize: fileSize ?? this.fileSize,
        fileSizeMb: fileSizeMb ?? this.fileSizeMb,
        fileType: fileType ?? this.fileType,
        mimeType: mimeType ?? this.mimeType,
      );

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
        id: json["id"],
        fileName: json["file_name"],
        filePath: json["file_path"],
        fileSize: json["file_size"],
        fileSizeMb: json["file_size_mb"]?.toDouble(),
        fileType: json["file_type"],
        mimeType: json["mime_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "file_name": fileName,
        "file_path": filePath,
        "file_size": fileSize,
        "file_size_mb": fileSizeMb,
        "file_type": fileType,
        "mime_type": mimeType,
      };
}
