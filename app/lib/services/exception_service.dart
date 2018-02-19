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
        print('FlutterError.onError caught an error');
        await reportErrorAndStackTrace(details.exception, details.stack);
      };
    }
  }


    /// Reports [error] along with its [stackTrace] to Sentry.io.
  Future<Null> reportError(dynamic error) async {
    if (!isDebug) {
      print('Caught error: $error');
      print('Reporting to Sentry.io...');

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
        print('Success! Event ID: ${response.eventId}');
      } else {
        print('Failed to report to Sentry.io: ${response.error}');
      }
    } else {
      throw error;
    }
  }

  Future<Null> reportErrorAndStackTrace(dynamic error, dynamic stackTrace) async {
    if (!isDebug) {
      print('Caught error: $error');
      print('Reporting to Sentry.io...');

      final SentryResponse response = await _sentry.captureException(
          exception: error,
          stackTrace: stackTrace,
      );

      if (response.isSuccessful) {
        print('Success! Event ID: ${response.eventId}');
      } else {
        print('Failed to report to Sentry.io: ${response.error}');
      }
    } else {
      throw error;
    }
  }
}