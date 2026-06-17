import 'package:flutter/cupertino.dart';
import 'package:omkar_sale/utils/extensions/string_extensopns.dart';

class Validator {
  static String? isValidEmail({required String email, required BuildContext context}) {
    if (RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(email.trim())) {
      return null;
    }
    return 'pleaseEnterValidEmail'.tr(context);
  }

  static String? isTextFieldEmpty({required String? value, required BuildContext context, String? errorMessage}) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage ?? 'fieldMustNotBeEmpty'.tr(context);
    }

    return null;
  }

  static String? isValidPassword({required String password, required BuildContext context, int passwordLength = 6}) {
    if (password.isEmpty) {
      return 'enterYourPassword'.tr(context);
    } else if (password.length < passwordLength) {
      return 'passwordMustBeOfSixCharacter'.tr(context);
    }
    return null;
  }

  static String? isValidConfirmPassword({required String confirmPassword, required String password, required BuildContext context}) {
    if (confirmPassword.isEmpty) {
      return 'enterYourConfirmPassword'.tr(context);
    } else if (confirmPassword != password) {
      return 'confirmPasswordDoesNotMatch'.tr(context);
    }
    return null;
  }

  /// 🔐 PIN Validation
  static String? isValidPin({required String? pin, required int requiredLength, required BuildContext context}) {
    if (pin == null || pin.isEmpty) {
      return 'enterYourPinlbl'.tr(context);
    } else if (pin.length < requiredLength) {
      return 'pinMustBeOfLength'.tr(context);
    } else if (!RegExp(r'^[0-9]+$').hasMatch(pin)) {
      return 'pinMustBeNumeric'.tr(context);
    }
    return null;
  }
}
