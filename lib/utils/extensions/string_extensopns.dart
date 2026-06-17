import 'package:flutter/cupertino.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

extension StringExtension on String {
  //
  String capitalize() => '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  //
  String makeItCompulsory() => '$this *';

  String translate(BuildContext context) => AppLocalization.of(context)?.getTranslatedValues(this) ?? this;
  // String tr(BuildContext context) {
  //   return AppLocalization.of(context)?.getTranslatedValues(this) ?? this;
  // }

  // //
  // String translateWithCompulsoryMark(final BuildContext context) => "${(AppLocalization.of(context)!.getTranslatedValues(this) ?? this).trim()} *";

  //
  // String getFirebaseError(final BuildContext context) {
  //   if (contains('firebase_auth/invalid-credential') || toLowerCase().contains('firebase_auth/invalid_login_credential')) {
  //     return 'invalidCredential'.translate(context);
  //   } else if (contains('firebase_auth/invalid-email')) {
  //     return 'invalidEmail'.translate(context);
  //   } else if (contains('firebase_auth/email-already-in-use')) {
  //     return 'emailAlreadyInUse'.translate(context);
  //   } else if (contains('firebase_auth/weak-password')) {
  //     return 'weakPassword'.translate(context);
  //   } else if (contains('firebase_auth/requires-recent-login')) {
  //     return 'loginAgainToDeleteAccount'.translate(context);
  //   }
  //   return this;
  // }

  void Print() {
    if (kDebugMode) {
      print(this);
    }
  }

  int toInt() {
    return int.parse(this);
  }

  double toDouble() {
    return double.parse(this);
  }
}

extension LocalizationExtension on String {
  String tr(BuildContext context, {Map<String, String>? namedArgs}) {
    var text = AppLocalization.of(context)?.getTranslatedValues(this) ?? this;
    if (namedArgs != null) {
      namedArgs.forEach((key, value) {
        text = text.replaceAll('{$key}', value);
      });
    }

    return text;
  }
}
