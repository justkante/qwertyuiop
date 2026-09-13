import 'package:creatify_mobile/data/models/responses/user_dto.dart';
import 'package:hive_flutter/adapters.dart';

class UserProfileAdapter extends TypeAdapter<UserDto> {
  @override
  final int typeId = 0; // Unique identifier for this class

  @override
  UserDto read(BinaryReader reader) {
    final fields = reader.readMap();
    return UserDto.fromJson(Map<String, dynamic>.from(fields));
  }

  @override
  void write(BinaryWriter writer, UserDto obj) {
    writer.writeMap(obj.toJson());
  }
}
