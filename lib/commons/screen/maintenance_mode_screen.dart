import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class MaintenanceModeScreen extends StatefulWidget {
  const MaintenanceModeScreen({super.key});

  @override
  State<MaintenanceModeScreen> createState() => _MaintenanceModeScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute<dynamic>(
      settings: routeSettings,
      builder: (_) => const MaintenanceModeScreen(),
    );
  }
}

class _MaintenanceModeScreenState extends State<MaintenanceModeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,

        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.sp(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cool Icon with a background glow
              Container(
                padding: EdgeInsets.all(20.sp(context)),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.settings_suggest_rounded,
                  size: 100.sp(context),
                  color: context.primaryColor.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: 40.sp(context)),

              // Title
              Text(
                'appUnderMaintenanceLbl'.tr(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.sp(context),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 15.sp(context)),

              // Subtitle
              Text(
                'appUnderMaintenanceDescLbl'.tr(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp(context),
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 50.sp(context)),

              CustomRoundedButtonWidget(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(Routes.splashScreen);
                },

                height: 55.sp(context),
                textStyle: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.bold),
                gradient: const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
                shadowColor: const Color(0xFF4A00E0),
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                text: 'retryLbl'.tr(context),
              ),

              // Refresh Button
              // SizedBox(
              //   width: double.infinity,
              //   height: 55.sp(context),
              //   child: ElevatedButton(
              //     onPressed: widget.onRefresh,
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: context.primaryColor.withValues(alpha: 0.7),
              //       foregroundColor: Colors.white,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(16),
              //       ),
              //       elevation: 0,
              //     ),
              //     child: const Text(
              //       'Check Again',
              //       style: TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(height: 20.sp(context)),
            ],
          ),
        ),
      ),
    );
  }
}
