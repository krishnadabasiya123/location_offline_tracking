import 'package:flutter/cupertino.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

extension SnackbarExtension on BuildContext {
  void showSnackBar({required String message, Color? backgroundColor, Duration duration = const Duration(milliseconds: 3000)}) {
    final overlayState = Overlay.of(this);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => ErrorMessageOverlayContainer(errorMessage: message, backgroundColor: backgroundColor ?? context.colorScheme.primary),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
