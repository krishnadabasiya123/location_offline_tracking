import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;
import 'package:omkar_sale/core/app/all_import_file.dart';

extension LoggerExtension on Object? {
  /// Standard Print Log
  void printLog([String tag = 'LOG']) {
    if (kDebugMode) {
      // We use 'this' to refer to the object the extension is called on
      print('--- $tag ---: ${toString()}');
    }
  }

  /// Advanced Developer Log (Better for large data/JSON)
  void log([String tag = 'DEBUG']) {
    if (kDebugMode) {
      dev.log(toString(), name: tag);
    }
  }

  /// Specific for Booleans
  void logBool([String tag = 'BOOL']) {
    if (kDebugMode) {
      if (this is bool) {
        final emoji = (this! as bool) ? '✅ TRUE' : '❌ FALSE';
        dev.log(emoji, name: tag);
      } else {
        dev.log('Value is not a boolean: $this', name: tag);
      }
    }
  }
}
