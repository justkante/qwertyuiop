import 'package:flutter/foundation.dart';

/// The environment.
enum Environmentx {
  /// Development environment.
  staging._('DEV'),

  /// Production environment.
  prod._('PROD'),

  /// Local environment for emulator testing.
  local._('LOCAL');

  /// The environment value.
  final String value;

  const Environmentx._(this.value);

  /// Returns the environment from the given [value].
  static Environmentx from(String? value) => switch (value) {
        'DEV' => Environmentx.staging,
        'PROD' => Environmentx.prod,
        'LOCAL' => Environmentx.local,
        _ => kReleaseMode ? Environmentx.prod : Environmentx.staging,
      };
}
