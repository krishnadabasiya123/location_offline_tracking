import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

void showLogoutConfirmationDialog(BuildContext context) {
  showDialog<void>(
    context: context,

    builder: (dialogContext) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Dialog(
        backgroundColor: context.colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: context.colorScheme.onSecondary.withValues(alpha: 0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- ICON SECTION ---
              Container(
                height: 64.sp(context),
                width: 64.sp(context),
                decoration: BoxDecoration(
                  color: AppThemeColors.redColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppThemeColors.redColor.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppThemeColors.redColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppThemeColors.redColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              // --- TEXT SECTION ---
              Text(
                'confirmLogout'.tr(context), // "Confirm Log Out?"
                style: TextStyle(
                  fontSize: 20.sp(context),
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onSecondary,
                ),
              ),
              SizedBox(height: 12.sp(context)),
              Text(
                'areYouSureYouWantToSignOut'.tr(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp(context),
                  color: context.colorScheme.onSecondary.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 32.sp(context)),

              // --- BUTTON SECTION ---
              Row(
                children: [
                  Expanded(
                    child: CustomRoundedButtonWidget(
                      text: 'cancelLbl'.tr(context),
                      onPressed: () => Navigator.of(context).pop(),
                      stretch: true,
                      height: 50.sp(context),
                      backgroundColor: context.colorScheme.secondary,
                      borderSide: BorderSide(color: context.colorScheme.onSecondary.withValues(alpha: 0.1)),
                      textStyle: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.bold),
                      // gradient: const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
                    ),
                  ),

                  SizedBox(width: 12.sp(context)),
                  Expanded(
                    child: CustomRoundedButtonWidget(
                      text: 'logOutLbl'.tr(context),
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.read<LogOutCubit>().logOutUser();
                      },
                      stretch: true,
                      height: 50.sp(context),
                      backgroundColor: context.colorScheme.primary,
                      borderSide: BorderSide(color: context.colorScheme.onSecondary.withValues(alpha: 0.1)),
                      textStyle: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
