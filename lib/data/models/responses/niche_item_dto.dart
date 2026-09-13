// To parse this JSON data, do
//
//     final nicheItemDto = nicheItemDtoFromJson(jsonString);

import 'dart:convert';

NicheItemDto nicheItemDtoFromJson(String str) => NicheItemDto.fromJson(json.decode(str));

String nicheItemDtoToJson(NicheItemDto data) => json.encode(data.toJson());

class NicheItemDto {
  final String? id;
  final String? name;
  final String? slug;
  final int? sortOrder;
  final List<NicheItemDto>? categories;

  NicheItemDto({
    this.id,
    this.name,
    this.slug,
    this.sortOrder,
    this.categories,
  });

  factory NicheItemDto.fromJson(Map<String, dynamic> json) => NicheItemDto(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        sortOrder: json["sort_order"],
        categories: json["categories"] == null
            ? []
            : List<NicheItemDto>.from(json["categories"]!.map((x) => NicheItemDto.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "sort_order": sortOrder,
        "categories":
            categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
      };
}
