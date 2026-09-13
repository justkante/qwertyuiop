import 'package:uuid/uuid.dart';

class UUIDGenerator {
  static const Uuid _uuid = Uuid();

  /// Generates a random UUID v4
  static String generateUUID() {
    return _uuid.v4();
  }

  /// Generates a UUID v5 using a namespace and name
  static String generateNameBasedUUID(String namespace, String name) {
    return _uuid.v5(namespace, name);
  }

  /// Generates a timestamp-based UUID v1
  static String generateTimeBasedUUID() {
    return _uuid.v1();
  }
}
