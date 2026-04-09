import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/notifications/notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // runZonedGuarded catches any uncaught async errors — prevents app crashes.
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };

    // Catch platform dispatcher errors
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('PlatformDispatcher error: $error');
      return true;
    };

    // Init locale for DateFormat (Russian)
    try {
      await initializeDateFormatting('ru_RU');
    } catch (e) {
      debugPrint('Locale init error: $e');
    }

    // Init Firebase (safe: app continues even if Firebase init fails)
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase init error: $e');
    }

    // Configure DI
    await configureDependencies();

    // Init notifications
    try {
      await getIt<NotificationService>().init();
    } catch (e) {
      debugPrint('Notifications init error: $e');
    }

    runApp(const MyHabitsApp());
  }, (error, stack) {
    debugPrint('Uncaught zone error: $error');
    debugPrint('Stack: $stack');
  });
}
