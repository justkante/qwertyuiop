// To parse this JSON data, do
//
//     final recommendedCreatorsDto = recommendedCreatorsDtoFromJson(jsonString);

import 'dart:convert';

import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';

RecommendedCreatorsDto recommendedCreatorsDtoFromJson(String str) =>
    RecommendedCreatorsDto.fromJson(json.decode(str));

String recommendedCreatorsDtoToJson(RecommendedCreatorsDto data) => json.encode(data.toJson());

class RecommendedCreatorsDto {
  final bool? success;
  final List<CreatorProfileDto>? data;
  final Meta? meta;

  RecommendedCreatorsDto({
    this.success,
    this.data,
    this.meta,
  });

  factory RecommendedCreatorsDto.fromJson(Map<String, dynamic> json) => RecommendedCreatorsDto(
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<CreatorProfileDto>.from(json["data"]!.map((x) => CreatorProfileDto.fromJson(x))),
        meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "meta": meta?.toJson(),
      };
}

class Meta {
  final bool? hasPreferences;

  Meta({
    this.hasPreferences,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        hasPreferences: json["has_preferences"],
      );

  Map<String, dynamic> toJson() => {
        "has_preferences": hasPreferences,
      };
}
