import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mongez/app.dart';
import 'package:mongez/core/di/services_locator.dart';
import 'package:mongez/core/utils/app_prefs.dart';
import 'package:mongez/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize Firebase in the background (not awaited) so the first frame
  // renders immediately. Firebase's init performs a network handshake that
  // can stall for several seconds on slow or unreachable links; awaiting it
  // here used to delay the whole app before the splash even appeared.
  // Crash reporting attaches as soon as init completes.
  if (!kIsWeb) {
    _initFirebase();
  }

  setup();
  await AppPrefs.init();

  runZonedGuarded(
    () => runApp(const MyApp()),
    (error, stack) {
      developer.log('Uncaught error: $error', name: 'Mongez');
      if (!kIsWeb) {
        try {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        } catch (_) {}
      }
    },
  );
}

/// Kicks off Firebase without blocking the UI thread. Safe to call as an
/// unawaited background task; failures are logged and ignored so a broken
/// Firebase config never prevents the app from running.
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  } catch (e) {
    developer.log('Firebase init failed: $e', name: 'Mongez');
  }
}
