import 'dart:developer';
import 'package:creatify_mobile/core/env/env.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

// MixPanel
final mixpanel = MixpanelService.instance;

class MixpanelService {
  static final MixpanelService _instance = MixpanelService._internal();
  static MixpanelService get instance => _instance;

  MixpanelService._internal();

  Mixpanel? _mixpanel;
  bool _isInitialized = false;

  Mixpanel? get mixpanel => _mixpanel;
  bool get isInitialized => _isInitialized;

  /// Initialize Mixpanel with your project token
  Future<void> initialize({Map<String, dynamic>? superProperties}) async {
    if (_isInitialized) {
      log('Mixpanel already initialized, skipping...');
      return;
    }

    try {
      _mixpanel = await Mixpanel.init(
        Env.mixpanelToken,
        trackAutomaticEvents: false,
        superProperties: superProperties,
      );
      _isInitialized = true;

      log('Mixpanel initialized successfully');

      _mixpanel!.setLoggingEnabled(true);
    } catch (e) {
      log('Failed to initialize Mixpanel: $e');
      _isInitialized = false;
    }
  }

  /// Track an event with optional properties
  void trackEvent(String eventName, {Map<String, dynamic>? properties}) async {
    if (!_isInitialized || _mixpanel == null) {
      log('Mixpanel not initialized, cannot track event: $eventName');
      return;
    }

    try {
      if (properties != null && properties.isNotEmpty) {
        await _mixpanel!.track(eventName, properties: properties);
      } else {
        await _mixpanel!.track(eventName);
      }
      log('Event tracked: $eventName');
    } catch (e) {
      log('Failed to track event: $eventName, Error: $e');
    }
  }

  /// Identify a user with a unique ID
  void identify(String userId) async {
    if (!_isInitialized || _mixpanel == null) {
      log('Mixpanel not initialized, cannot identify user');
      return;
    }

    try {
      await _mixpanel!.identify(userId);
      log('User identified: $userId');
    } catch (e) {
      log('Failed to identify user: $e');
    }
  }

  /// Set user properties
  void setUserProperties(Map<String, dynamic> properties) {
    if (!_isInitialized || _mixpanel == null) {
      log('Mixpanel not initialized, cannot set user properties');
      return;
    }

    try {
      _mixpanel!.getPeople().set('\$name', properties['\$name']);
      _mixpanel!.getPeople().set('\$email', properties['\$email']);

      // Set any additional properties
      properties.forEach((key, value) {
        if (key != '\$name' && key != '\$email') {
          _mixpanel!.getPeople().set(key, value);
        }
      });
      log('User properties set successfully');
    } catch (e) {
      log('Failed to set user properties: $e');
    }
  }

  /// Set a single user property
  void setUserProperty(String property, dynamic value) {
    if (!_isInitialized || _mixpanel == null) {
      log('Mixpanel not initialized, cannot set user property');
      return;
    }

    try {
      _mixpanel!.getPeople().set(property, value);
      log('User property set: $property');
    } catch (e) {
      log('Failed to set user property: $e');
    }
  }

  /// Increment a numeric user property
  void incrementUserProperty(String property, [double by = 1]) {
    if (!_isInitialized || _mixpanel == null) {
      log('Mixpanel not initialized, cannot increment user property');
      return;
    }

    try {
      _mixpanel!.getPeople().increment(property, by);
      log('User property incremented: $property by $by');
    } catch (e) {
      log('Failed to increment user property: $e');
    }
  }

  /// Register super properties that will be sent with all events
  void registerSuperProperties(Map<String, dynamic> properties) async {
    if (!_isInitialized || _mixpanel == null) {
      log('Mixpanel not initialized, cannot register super properties');
      return;
    }

    try {
      await _mixpanel!.registerSuperProperties(properties);
      log('Super properties registered');
    } catch (e) {
      log('Failed to register super properties: $e');
    }
  }

  /// Time an event (start timing)
  void timeEvent(String eventName) {
    if (!_isInitialized || _mixpanel == null) {
      log('Mixpanel not initialized, cannot time event');
      return;
    }

    try {
      _mixpanel!.timeEvent(eventName);
      log('Started timing event: $eventName');
    } catch (e) {
      log('Failed to time event: $e');
    }
  }

  /// Reset the user (clear identification and super properties)
  void reset() async {
    if (!_isInitialized || _mixpanel == null) {
      log('Mixpanel not initialized, cannot reset');
      return;
    }

    try {
      await _mixpanel!.reset();
      log('Mixpanel reset successfully');
    } catch (e) {
      log('Failed to reset Mixpanel: $e');
    }
  }

  /// Flush events to Mixpanel servers
  void flush() async {
    if (!_isInitialized || _mixpanel == null) {
      log('Mixpanel not initialized, cannot flush');
      return;
    }

    try {
      await _mixpanel!.flush();
      log('Mixpanel events flushed');
    } catch (e) {
      log('Failed to flush Mixpanel events: $e');
    }
  }

  /// Dispose and clean up resources
  void dispose() {
    if (_isInitialized && _mixpanel != null) {
      flush();
      _isInitialized = false;
      _mixpanel = null;
      log('Mixpanel service disposed');
    }
  }
}
