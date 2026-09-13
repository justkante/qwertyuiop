// To parse this JSON data, do
//
//     final notificationDto = notificationDtoFromJson(jsonString);

import 'dart:convert';

NotificationDto notificationDtoFromJson(String str) => NotificationDto.fromJson(json.decode(str));

String notificationDtoToJson(NotificationDto data) => json.encode(data.toJson());

class NotificationDto {
  final bool? success;
  final List<NotificationsItemDto>? data;
  final int? total;
  final int? unreadCount;

  NotificationDto({
    this.success,
    this.data,
    this.total,
    this.unreadCount,
  });

  NotificationDto copyWith({
    bool? success,
    List<NotificationsItemDto>? data,
    int? total,
    int? unreadCount,
  }) =>
      NotificationDto(
        success: success ?? this.success,
        data: data ?? this.data,
        total: total ?? this.total,
        unreadCount: unreadCount ?? this.unreadCount,
      );

  factory NotificationDto.fromJson(Map<String, dynamic> json) => NotificationDto(
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<NotificationsItemDto>.from(
                json["data"]!.map((x) => NotificationsItemDto.fromJson(x))),
        total: json["total"],
        unreadCount: json["unread_count"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "total": total,
        "unread_count": unreadCount,
      };
}

class NotificationsItemDto {
  final String? id;
  final String? userId;
  final String? title;
  final String? description;
  final String? type;
  final Data? data;
  final bool? isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  NotificationsItemDto({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.type,
    this.data,
    this.isRead,
    this.readAt,
    this.createdAt,
  });

  NotificationsItemDto copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? type,
    Data? data,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) =>
      NotificationsItemDto(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        description: description ?? this.description,
        type: type ?? this.type,
        data: data ?? this.data,
        isRead: isRead ?? this.isRead,
        readAt: readAt ?? this.readAt,
        createdAt: createdAt ?? this.createdAt,
      );

  factory NotificationsItemDto.fromJson(Map<String, dynamic> json) => NotificationsItemDto(
        id: json["id"],
        userId: json["user_id"],
        title: json["title"],
        description: json["description"],
        type: json["type"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        isRead: json["is_read"],
        readAt: json["read_at"] == null ? null : DateTime.parse(json["read_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "title": title,
        "description": description,
        "type": type,
        "data": data?.toJson(),
        "is_read": isRead,
        "read_at": readAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
      };
}

class Data {
  final String? bookingId;
  final String? cancelledBy;
  final bool? refundProcessed;
  final String? recruiterId;
  final String? recruiterName;
  final DateTime? availableAt;
  final String? amountCredited;
  final bool? autoExtended;
  final String? deliverableId;
  final int? revisionCount;
  final DateTime? newEndDate;
  final String? extensionRequestId;

  Data({
    this.bookingId,
    this.cancelledBy,
    this.refundProcessed,
    this.recruiterId,
    this.recruiterName,
    this.availableAt,
    this.amountCredited,
    this.autoExtended,
    this.deliverableId,
    this.revisionCount,
    this.newEndDate,
    this.extensionRequestId,
  });

  Data copyWith({
    String? bookingId,
    String? cancelledBy,
    bool? refundProcessed,
    String? recruiterId,
    String? recruiterName,
    DateTime? availableAt,
    String? amountCredited,
    bool? autoExtended,
    String? deliverableId,
    int? revisionCount,
    DateTime? newEndDate,
    String? extensionRequestId,
  }) =>
      Data(
        bookingId: bookingId ?? this.bookingId,
        cancelledBy: cancelledBy ?? this.cancelledBy,
        refundProcessed: refundProcessed ?? this.refundProcessed,
        recruiterId: recruiterId ?? this.recruiterId,
        recruiterName: recruiterName ?? this.recruiterName,
        availableAt: availableAt ?? this.availableAt,
        amountCredited: amountCredited ?? this.amountCredited,
        autoExtended: autoExtended ?? this.autoExtended,
        deliverableId: deliverableId ?? this.deliverableId,
        revisionCount: revisionCount ?? this.revisionCount,
        newEndDate: newEndDate ?? this.newEndDate,
        extensionRequestId: extensionRequestId ?? this.extensionRequestId,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        bookingId: json["booking_id"],
        cancelledBy: json["cancelled_by"],
        refundProcessed: json["refund_processed"],
        recruiterId: json["recruiter_id"],
        recruiterName: json["recruiter_name"],
        availableAt: json["available_at"] == null ? null : DateTime.parse(json["available_at"]),
        amountCredited: json["amount_credited"],
        autoExtended: json["auto_extended"],
        deliverableId: json["deliverable_id"],
        revisionCount: json["revision_count"],
        newEndDate: json["new_end_date"] == null ? null : DateTime.parse(json["new_end_date"]),
        extensionRequestId: json["extension_request_id"],
      );

  Map<String, dynamic> toJson() => {
        "booking_id": bookingId,
        "cancelled_by": cancelledBy,
        "refund_processed": refundProcessed,
        "recruiter_id": recruiterId,
        "recruiter_name": recruiterName,
        "available_at": availableAt?.toIso8601String(),
        "amount_credited": amountCredited,
        "auto_extended": autoExtended,
        "deliverable_id": deliverableId,
        "revision_count": revisionCount,
        "new_end_date":
            "${newEndDate!.year.toString().padLeft(4, '0')}-${newEndDate!.month.toString().padLeft(2, '0')}-${newEndDate!.day.toString().padLeft(2, '0')}",
        "extension_request_id": extensionRequestId,
      };
}
