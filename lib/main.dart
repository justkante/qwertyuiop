import 'dart:async';

import 'package:creatify_mobile/core/env/env.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:creatify_mobile/app.dart';
import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/storage/hive-storage/hive_storage.dart';
import 'package:creatify_mobile/core/storage/hive-storage/hive_storage_service.dart';
import 'package:creatify_mobile/core/third-party/environment.dart';
import 'package:creatify_mobile/core/utils/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

EventBus eventBus = EventBus();
ValueNotifier<String> environmentNotifier = ValueNotifier<String>('');

Future<void> main() async {
  runZonedGuarded(() async {
    //WidgetsFlutterBinding.ensureInitialized();
    SentryWidgetsFlutterBinding.ensureInitialized();

    // Read the environment from the ENVIRONMENT variable
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'prod');
    environmentNotifier.value = environment;

    final env = switch (environment) {
      'prod' => Environmentx.prod,
      'dev' => Environmentx.staging,
      'local' => Environmentx.local,
      _ => Environmentx.prod,
    };

    await initializeCore(environment: env);

    Stripe.publishableKey =
        environment == 'dev' ? Env.stripePublishableKey : Env.prodStripePublishableKey;

    final HiveStorageBase initializeStorageService = HiveStorageService();
    await initializeStorageService.init();

    eventBus.on().listen((event) {});

    final container = ProviderContainer(
      overrides: [
        hiveStorageService.overrideWithValue(initializeStorageService),
      ],
    );

    await SentryFlutter.init(
      (options) {
        options.dsn =
            'https://4d96aad831a0cc27ac86f1b667325c14@o4508468046921728.ingest.us.sentry.io/4510318500642816';
        // Adds request headers and IP for users, for more info visit:
        // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
        options.sendDefaultPii = true;
        options.enableLogs = true;
        // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
        // We recommend adjusting this value in production.
        options.tracesSampleRate = 1.0;
        // The sampling rate for profiling is relative to tracesSampleRate
        // Configure Session Replay
        options.replay.sessionSampleRate = 0.1;
        options.replay.onErrorSampleRate = 1.0;
      },
      appRunner: () => runApp(
        SentryWidget(
          child: UncontrolledProviderScope(
            container: container,
            child: const MyApp(
              env: environment,
            ),
          ),
        ),
      ),
    );
  }, (error, stack) {
    logger.error(error.toString());
  });
}
