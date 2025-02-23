import 'dart:async';

import 'package:flutter/cupertino.dart';
import '../../app/flavor_config.dart';
import '../../app/locator.dart';
import '../models/user_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryReporter {
  String get _sentryDsn => locator<AppFlavorConfig>().sentryDsn;

  Future<void> setup(Widget child) async {
    await SentryFlutter.init(
      (options) {
        options.dsn = _sentryDsn;
        options.tracesSampleRate = 1.0;
        options.attachScreenshot = true;
        options.enablePrintBreadcrumbs = true;
      },
      appRunner: () => runApp(
        SentryScreenshotWidget(
          child: DefaultAssetBundle(
            bundle: SentryAssetBundle(
              enableStructuredDataTracing: true,
            ),
            child: child,
          ),
        ),
      ),
    );
    await setupPerformance();
  }

  Future<void> setUser(UserModel user) async {
    await Sentry.configureScope(
      (scope) => scope.setUser(SentryUser(
        email: user.email,
      )),
    );
  }

  Future<void> setupPerformance() async {
    final transaction = Sentry.startTransaction('processOrderBatch', 'task');
    try {
      await processOrderBatch(transaction);
    } catch (exc) {
      transaction.throwable = exc;
      transaction.status = const SpanStatus.internalError();
    } finally {
      await transaction.finish();
    }
  }

  Future<void> processOrderBatch(ISentrySpan span) async {
    final innerSpan = span.startChild('task', description: 'operation');
    try {
      await Future.delayed(const Duration(seconds: 1));
    } catch (exc) {
      innerSpan.throwable = exc;
      innerSpan.status = const SpanStatus.notFound();
    } finally {
      await innerSpan.finish();
    }
  }

  Future<SentryId> reportError(dynamic error, StackTrace stackTrace) {
    return Sentry.captureException(error, stackTrace: stackTrace);
  }

  Future<SentryId> reportNonError(dynamic error) {
    return Sentry.captureMessage(error);
  }
} 