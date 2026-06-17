import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

extension CustomDialogExtension on BuildContext {
  Future<void> showSessionExpired() async {
    await showCustomDialog<void>(
      title: 'sessionExpiredLbl'.tr(this),
      message: 'sessionExpiredDesc'.tr(this),
      isDismissible: false, 
      icon: Icon(
        Icons.vpn_key_off_rounded,
        color: AppThemeColors.amberColor,
        size: 32.sp(this),
      ),
      confirmButtonText: 'logInBtnLbl'.tr(this),
      onConfirm: () async {
        await read<AuthCubit>().signOut();

        if (mounted) {
          Navigator.of(this).pushReplacementNamed(Routes.signInScreen);
        }
      },
    );
  }
}
