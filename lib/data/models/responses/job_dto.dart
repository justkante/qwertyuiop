import 'dart:convert';
import 'user_dto.dart';
import 'niche_item_dto.dart';
import 'job_application_dto.dart';

JobDto jobDtoFromJson(String str) => JobDto.fromJson(json.decode(str));

String jobDtoToJson(JobDto data) => json.encode(data.toJson());

class JobDto {
  final String? id;
  final String? userId;
  final String? categoryId;
  final String? title;
  final String? description;
  final String? location;
  final double? price;
  final String? currency;
  final String? type;
  final String? workMode;
  final String? startDate;
  final String? startTime;
  final String? duration;
  final String? status;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isFavorited;
  final int? applicationsCount; // Add this
  final List<JobApplicationDto>? applications; // Add this
  final UserDto? user;
  final NicheItemDto? category;

  JobDto({
    this.id,
    this.userId,
    this.categoryId,
    this.title,
    this.description,
    this.location,
    this.price,
    this.currency,
    this.type,
    this.workMode,
    this.startDate,
    this.startTime,
    this.duration,
    this.status,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.isFavorited,
    this.applicationsCount,
    this.applications,
    this.user,
    this.category,
  });

  JobDto copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? title,
    String? description,
    String? location,
    double? price,
    String? currency,
    String? type,
    String? workMode,
    String? startDate,
    String? startTime,
    String? duration,
    String? status,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorited,
    int? applicationsCount, // Add this
    List<JobApplicationDto>? applications, // Add this
    UserDto? user,
    NicheItemDto? category,
  }) =>
      JobDto(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        categoryId: categoryId ?? this.categoryId,
        title: title ?? this.title,
        description: description ?? this.description,
        location: location ?? this.location,
        price: price ?? this.price,
        currency: currency ?? this.currency,
        type: type ?? this.type,
        workMode: workMode ?? this.workMode,
        startDate: startDate ?? this.startDate,
        startTime: startTime ?? this.startTime,
        duration: duration ?? this.duration,
        status: status ?? this.status,
        expiresAt: expiresAt ?? this.expiresAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isFavorited: isFavorited ?? this.isFavorited,
        applicationsCount: applicationsCount ?? this.applicationsCount, // Add this
        applications: applications ?? this.applications, // Add this
        user: user ?? this.user,
        category: category ?? this.category,
      );

  factory JobDto.fromJson(Map<String, dynamic> json) => JobDto(
        id: json["id"],
        userId: json["user_id"],
        categoryId: json["category_id"],
        title: json["title"],
        description: json["description"],
        location: json["location"],
        price: json["price"] == null ? null : double.tryParse(json["price"].toString()),
        currency: json["currency"],
        type: json["type"],
        workMode: json["work_mode"],
        startDate: json["start_date"],
        startTime: json["start_time"],
        duration: json["duration"],
        status: json["status"],
        expiresAt: json["expires_at"] == null ? null : DateTime.tryParse(json["expires_at"].toString()),
        createdAt: json["created_at"] == null ? null : DateTime.tryParse(json["created_at"].toString()),
        updatedAt: json["updated_at"] == null ? null : DateTime.tryParse(json["updated_at"].toString()),
        isFavorited: json["is_favorited"],
        applicationsCount: json["applications_count"], // Add this
        applications: json["applications"] == null ? null : List<JobApplicationDto>.from(json["applications"].map((x) => JobApplicationDto.fromJson(x))), // Add this
        user: json["user"] == null ? null : UserDto.fromJson(json["user"]),
        category: json["category"] == null ? null : NicheItemDto.fromJson(json["category"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "category_id": categoryId,
        "title": title,
        "description": description,
        "location": location,
        "price": price,
        "currency": currency,
        "type": type,
        "work_mode": workMode,
        "start_date": startDate,
        "start_time": startTime,
        "duration": duration,
        "status": status,
        "expires_at": expiresAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "is_favorited": isFavorited,
        "applications_count": applicationsCount, // Add this
        "applications": applications == null ? null : List<dynamic>.from(applications!.map((x) => x.toJson())), // Add this
        "user": user?.toJson(),
        "category": category?.toJson(),
      };
}
