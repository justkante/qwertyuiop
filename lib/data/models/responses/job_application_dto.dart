import 'dart:convert';
import 'user_dto.dart';
import 'job_dto.dart';

JobApplicationDto jobApplicationDtoFromJson(String str) => JobApplicationDto.fromJson(json.decode(str));

String jobApplicationDtoToJson(JobApplicationDto data) => json.encode(data.toJson());

class JobApplicationDto {
  final String? id;
  final String? jobId;
  final String? userId;
  final String? pitch;
  final String? portfolioLink;
  final List<String>? attachments;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserDto? user;
  final JobDto? job;

  JobApplicationDto({
    this.id,
    this.jobId,
    this.userId,
    this.pitch,
    this.portfolioLink,
    this.attachments,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.job,
  });

  JobApplicationDto copyWith({
    String? id,
    String? jobId,
    String? userId,
    String? pitch,
    String? portfolioLink,
    List<String>? attachments,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserDto? user,
    JobDto? job,
  }) =>
      JobApplicationDto(
        id: id ?? this.id,
        jobId: jobId ?? this.jobId,
        userId: userId ?? this.userId,
        pitch: pitch ?? this.pitch,
        portfolioLink: portfolioLink ?? this.portfolioLink,
        attachments: attachments ?? this.attachments,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        user: user ?? this.user,
        job: job ?? this.job,
      );

  factory JobApplicationDto.fromJson(Map<String, dynamic> json) => JobApplicationDto(
        id: json["id"],
        jobId: json["job_id"],
        userId: json["user_id"],
        pitch: json["pitch"],
        portfolioLink: json["portfolio_link"],
        attachments: json["attachments"] == null ? null : List<String>.from(json["attachments"].map((x) => x)),
        status: json["status"],
        createdAt: json["created_at"] == null ? null : DateTime.tryParse(json["created_at"].toString()),
        updatedAt: json["updated_at"] == null ? null : DateTime.tryParse(json["updated_at"].toString()),
        user: json["user"] == null ? null : UserDto.fromJson(json["user"]),
        job: json["job"] == null ? null : JobDto.fromJson(json["job"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "job_id": jobId,
        "user_id": userId,
        "pitch": pitch,
        "portfolio_link": portfolioLink,
        "attachments": attachments == null ? null : List<dynamic>.from(attachments!.map((x) => x)),
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "user": user?.toJson(),
        "job": job?.toJson(),
      };
}
