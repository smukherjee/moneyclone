import 'package:flutter/foundation.dart';
import 'package:money_clone/utils/logging_service.dart';

/// A utility class to help with running expensive operations off the main thread
class ComputeHelper {
  static final LoggingService _logger = LoggingService();

  /// Run a computation in a separate isolate and return the result
  static Future<R> runAsync<P, R>(
    ComputeCallback<P, R> callback,
    P param,
  ) async {
    // For web, we don't use compute as it's not fully supported
    if (kIsWeb) {
      return callback(param);
    }

    try {
      // For native platforms, use compute to run in a separate isolate
      return await compute(callback, param);
    } catch (e) {
      // If compute fails for any reason, fall back to running on the main thread
      _logger.warning(
        'ComputeHelper: Error using compute - falling back to main thread execution',
        e,
      );
      return callback(param);
    }
  }
}
