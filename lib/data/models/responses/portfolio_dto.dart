// To parse this JSON data, do
//
//     final portfolioDto = portfolioDtoFromJson(jsonString);

import 'dart:convert';

import 'package:creatify_mobile/view/utils/extensions.dart';

PortfolioDto portfolioDtoFromJson(String str) => PortfolioDto.fromJson(json.decode(str));

String portfolioDtoToJson(PortfolioDto data) => json.encode(data.toJson());

class PortfolioDto {
  final bool? success;
  final List<PortfolioItem>? portfolioItems;
  final int? totalCount;
  final int? remainingSlots;
  final StorageSummary? storageSummary;

  PortfolioDto({
    this.success,
    this.portfolioItems,
    this.totalCount,
    this.remainingSlots,
    this.storageSummary,
  });

  factory PortfolioDto.fromJson(Map<String, dynamic> json) => PortfolioDto(
        success: json["success"],
        portfolioItems: json["data"] == null
            ? []
            : List<PortfolioItem>.from(json["data"]!.map((x) => PortfolioItem.fromJson(x))),
        totalCount: json["total_count"],
        remainingSlots: json["remaining_slots"],
        storageSummary: json["storage_summary"] == null
            ? null
            : StorageSummary.fromJson(json["storage_summary"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": portfolioItems == null
            ? []
            : List<dynamic>.from(portfolioItems!.map((x) => x.toJson())),
        "total_count": totalCount,
        "remaining_slots": remainingSlots,
        "storage_summary": storageSummary?.toJson(),
      };
}

class PortfolioItem {
  final String? id;
  final String? userId;
  final MediaType? mediaType;
  final String? fileName;
  final String? filePath;
  final String? cloudinaryPublicId;
  final int? fileSize;
  final String? mimeType;
  final int? sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PortfolioItem({
    this.id,
    this.userId,
    this.mediaType,
    this.fileName,
    this.filePath,
    this.cloudinaryPublicId,
    this.fileSize,
    this.mimeType,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) => PortfolioItem(
        id: json["id"],
        userId: json["user_id"],
        mediaType: mediaTypes.map[json["media_type"]],
        fileName: json["file_name"],
        filePath: json["file_path"],
        cloudinaryPublicId: json["cloudinary_public_id"],
        fileSize: json["file_size"],
        mimeType: json["mime_type"],
        sortOrder: json["sort_order"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "media_type": mediaType,
        "file_name": fileName,
        "file_path": filePath,
        "cloudinary_public_id": cloudinaryPublicId,
        "file_size": fileSize,
        "mime_type": mimeType,
        "sort_order": sortOrder,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class StorageSummary {
  final int? images;
  final int? videos;
  final int? documents;

  StorageSummary({
    this.images,
    this.videos,
    this.documents,
  });

  factory StorageSummary.fromJson(Map<String, dynamic> json) => StorageSummary(
        images: json["images"],
        videos: json["videos"],
        documents: json["documents"],
      );

  Map<String, dynamic> toJson() => {
        "images": images,
        "videos": videos,
        "documents": documents,
      };
}

enum MediaType {
  image,
  video,
  document,
  audio,
}

final mediaTypes = EnumValues({
  "document": MediaType.document,
  "image": MediaType.image,
  "video": MediaType.video,
  "audio": MediaType.audio,
});
