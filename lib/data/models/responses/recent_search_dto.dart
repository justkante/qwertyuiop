import 'dart:convert';

RecentSearchDto recentSearchDtoFromJson(String str) => RecentSearchDto.fromJson(json.decode(str));

String recentSearchDtoToJson(RecentSearchDto data) => json.encode(data.toJson());

class RecentSearchDto {
  final String? id;
  final String? userId;
  final String? query;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RecentSearchDto({
    this.id,
    this.userId,
    this.query,
    this.createdAt,
    this.updatedAt,
  });

  factory RecentSearchDto.fromJson(Map<String, dynamic> json) => RecentSearchDto(
        id: json["id"],
        userId: json["user_id"],
        query: json["query"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "query": query,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
