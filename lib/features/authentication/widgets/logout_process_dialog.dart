import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

void showloadingDialog(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: LogOutProcessDialog(message: message),
      );
    },
  );
}

class LogOutProcessDialog extends StatelessWidget {
  const LogOutProcessDialog({required this.message, super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 30.sp(context),
            horizontal: 20.sp(context),
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(30.sp(context)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomCircularProgressIndicator(),
              SizedBox(height: 10.sp(context)),
              Text(
                message.tr(context),
                style: TextStyle(
                  fontSize: 18.sp(context),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
