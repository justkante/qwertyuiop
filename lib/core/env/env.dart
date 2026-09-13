import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
final class Env {
  @EnviedField(varName: 'DOJAH_WIDGET_ID')
  static final String dojohWidgetId = _Env.dojohWidgetId;

  @EnviedField(varName: 'PROD_DOJAH_WIDGET_ID')
  static final String prodDojahWidgetId = _Env.prodDojahWidgetId;

  @EnviedField(varName: 'PUSHER_APP_KEY')
  static final String pusherAppKey = _Env.pusherAppKey;

  @EnviedField(varName: 'PROD_PUSHER_APP_KEY')
  static final String prodPusherAppKey = _Env.prodPusherAppKey;

  @EnviedField(varName: 'PUSHER_CLUSTER')
  static final String pusherCluster = _Env.pusherCluster;

  @EnviedField(varName: 'ONESIGNAL_APP_ID')
  static final String oneSignalAppId = _Env.oneSignalAppId;

  @EnviedField(varName: 'GOOGLE_WEB_CLIENT_ID')
  static final String googleWebClientId = _Env.googleWebClientId;

  @EnviedField(varName: 'GOOGLE_ANDROID_CLIENT_ID')
  static final String googleAndroidClientId = _Env.googleAndroidClientId;

  @EnviedField(varName: 'GOOGLE_IOS_CLIENT_ID')
  static final String googleIosClientId = _Env.googleIosClientId;

  @EnviedField(varName: 'MIXPANEL_TOKEN')
  static final String mixpanelToken = _Env.mixpanelToken;

  @EnviedField(varName: 'STRIPE_PUBLISHABLE_KEY')
  static final String stripePublishableKey = _Env.stripePublishableKey;

  @EnviedField(varName: 'PROD_STRIPE_PUBLISHABLE_KEY')
  static final String prodStripePublishableKey = _Env.prodStripePublishableKey;
}
