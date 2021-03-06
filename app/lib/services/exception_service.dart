import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry/sentry.dart';

import '../dsn.dart';


class ExceptionService {
  final SentryClient _sentry = new SentryClient(dsn: dsn);
  static bool isDebug = false;
  

    // Singleton
  static final ExceptionService _exceptionService = new ExceptionService._internal();

  factory ExceptionService() => _exceptionService;

  ExceptionService._internal () {
    assert(() => isDebug = true); 
    if (!isDebug) {
      FlutterError.onError = (FlutterErrorDetails details) async {
        debugPrint('FlutterError.onError caught an error');
        await reportErrorAndStackTrace(details.exception, details.stack);
      };
    }
  }


    /// Reports [error] (either an [Exception] or an [Error]) to Sentry.io.
  Future<Null> reportError(dynamic error) async {
    if (!isDebug) {
      debugPrint('Caught error: $error');
      debugPrint('Reporting to Sentry.io...');

      SentryResponse response;
      if (error is Error) {
        response = await _sentry.captureException(
          exception: error,
          stackTrace: error.stackTrace,
        );
      } else {
        response = await _sentry.captureException(
          exception: error
        );
      }

      if (response.isSuccessful) {
        debugPrint('Success! Event ID: ${response.eventId}');
      } else {
        debugPrint('Failed to report to Sentry.io: ${response.error}');
      }
    } else {
      throw error;
    }
  }

  Future<Null> reportErrorAndStackTrace(dynamic error, dynamic stackTrace) async {
    if (!isDebug) {
      debugPrint('Caught error: $error');
      debugPrint('Reporting to Sentry.io...');

      final SentryResponse response = await _sentry.captureException(
          exception: error,
          stackTrace: stackTrace,
      );

      if (response.isSuccessful) {
        debugPrint('Success! Event ID: ${response.eventId}');
      } else {
        debugPrint('Failed to report to Sentry.io: ${response.error}');
      }
    } else {
      throw error;
    }
  }
}