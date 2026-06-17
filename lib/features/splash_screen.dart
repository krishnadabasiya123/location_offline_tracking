import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/commons/cubits/app_config_cubit.dart';
import 'package:omkar_sale/commons/models/app_config.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();

  static Route<dynamic> route(RouteSettings settings) => CupertinoPageRoute(
    settings: settings,
    builder: (_) => const SplashScreen(),
  );
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _driftController;

  @override
  void initState() {
    super.initState();
    Future.microtask(getAppSettings);

    // 2. Setup Background Drift Animation
    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  Future<void> getAppSettings() async {
    await context.read<AppConfigCubit>().fetchAppConfig();
  }

  /// Shows the Modern Animated Dialog
  void _showModernUpdateDialog(String version, String url) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => ForceUpdateDialog(
        version: version,
        onUpdate: () => _openStore(url),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim1, child: child),
      ),
    );
  }

  void _openStore(String url) {
    print('Launch Store URL: $url');
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> handlePostFetchLogic({required AppConfig appConfig}) async {
    // Note: Replace 'dynamic' with your actual 'AppConfigModel' type`

    var isMaintenance = false;
    var isUpdateEnabled = false;
    var remoteVersion = '';
    var storeUrl = '';

    // 1. EXTRACT DATA BASED ON PLATFORM
    if (Platform.isAndroid) {
      isMaintenance = appConfig.maintenanceMode.android;
      isUpdateEnabled = appConfig.forceUpdate.android.enable;
      remoteVersion = appConfig.forceUpdate.android.version;
      storeUrl = appConfig.forceUpdate.android.url;
    } else if (Platform.isIOS) {
      isMaintenance = appConfig.maintenanceMode.ios;
      isUpdateEnabled = appConfig.forceUpdate.ios.enable;
      remoteVersion = appConfig.forceUpdate.ios.version;
      storeUrl = appConfig.forceUpdate.ios.url;
    }

    // 2. CHECK MAINTENANCE MODE
    if (isMaintenance) {
      if (!mounted) return;
      // Navigate to your maintenance screen
      Navigator.of(context).pushReplacementNamed(Routes.maintenanceScreen);
      return;
    }

    // 3. CHECK FORCE UPDATE
    if (isUpdateEnabled) {
      try {
        final needsUpdate = await UiUtils.shouldUpdate(remoteVersion);

        if (needsUpdate && mounted) {
          _showModernUpdateDialog(remoteVersion, storeUrl);
          return;
        }
      } catch (e) {
        log('Force Update Error', error: e);
      }
    }

    // 4. NORMAL NAVIGATION FLOW
    // Add a slight delay for splash effect if needed, then navigate
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    if (SettingLocalRepository.instance.getIsOpenFirstTime()) {
      // Navigate to Onboarding or Language Selection
      // Navigator.pushReplacementNamed(context, Routes.onboardingScreen);
      return;
    }

    if (context.read<AuthCubit>().state is Authenticated) {
      Navigator.of(context).pushReplacementNamed(Routes.mainScreen);
    } else {
      Navigator.pushReplacementNamed(context, Routes.signInScreen);
    }
  }

  @override
  void dispose() {
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AppConfigCubit, AppConfigState>(
        listener: (context, state) async {
          if (state is AppConfigFetchSuccess) {
            // Future.delayed(const Duration(seconds: 2), () {
            //   if (SettingLocalRepository.instance.getIsOpenFirstTime()) {
            //     return;
            //   }
            //   // if ((state.appConfig.maintenanceMode.android && Platform.isAndroid) || (state.appConfig.maintenanceMode.ios && Platform.isIOS)) {
            //   //   Navigator.of(context).pushReplacementNamed(Routes.maintenanceScreen);
            //   //   return;
            //   // } else
            //   if (context.read<AuthCubit>().state is Authenticated) {
            //     Navigator.of(context).pushReplacementNamed(Routes.mainScreen);
            //     return;
            //   } else {
            //     Navigator.pushReplacementNamed(context, Routes.signInScreen);
            //   }
            // });

            handlePostFetchLogic(appConfig: state.appConfig);
          }
        },
        builder: (context, state) {
          if (state is AppConfigFetchFailure) {
            return CustomErrorWidget(
              errorType: state.exception.type,
              onRetry: getAppSettings,
            );
          }

          return Stack(children: [_buildBackgroundDrift(), _buildMainUI()]);
        },
      ),
    );
  }

  // --- UI Components ---

  Widget _buildBackgroundDrift() {
    return AnimatedBuilder(
      animation: _driftController,
      builder: (context, _) {
        final val = _driftController.value;
        return Stack(
          children: [
            // Top Right Circle
            Positioned(
              top: -80.sp(context) + (val * 50),
              right: -100.sp(context) + (val * 50),
              child: _blurCircle(
                context.dpWidth(context.isMobile ? 0.7 : 0.4),
                context.primaryColor.withValues(alpha: 0.12),
              ),
            ),
            // Bottom Left Circle
            Positioned(
              bottom: -50.sp(context) - (val * 50),
              left: -80.sp(context) - (val * 50),
              child: _blurCircle(
                context.dpWidth(context.isMobile ? 0.8 : 0.5),
                context.primaryColor.withValues(alpha: 0.08),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainUI() {
    return Column(
      children: [
        const Spacer(),
        _buildLogoEntrance(),
        const Spacer(),
        _buildFooterSlide(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildLogoEntrance() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogoCard(),
            SizedBox(height: 30.sp(context)),
            Text(
              'Omkar Industries Ltd.',
              style: GoogleFonts.manrope(
                fontSize: 30.sp(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Where Hygiene Meets Freshness',
              style: GoogleFonts.manrope(
                fontSize: 16.sp(context),
                color: context.colorScheme.onSecondary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterSlide() {
    return FutureBuilder<({String version, String buildCode})>(
      future: UiUtils.getInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final (:version, :buildCode) = snapshot.data!;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 20, end: 0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) =>
              Transform.translate(offset: Offset(0, value), child: child),
          child: Text(
            '$version • Build $buildCode',
            style: TextStyle(color: Colors.grey, fontSize: 12.sp(context)),
          ),
        );
      },
    );
  }

  // --- Helper Widgets ---

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
      ),
    );
  }

  Widget _buildLogoCard() {
    return Container(
      width: context.dpWidth(context.isMobile ? 0.4 : 0.2),
      height: context.dpWidth(context.isMobile ? 0.4 : 0.2),
      padding: EdgeInsets.all(20.sp(context)),
      decoration: BoxDecoration(
        color: AppThemeColors.whiteColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const CustomImageWidget(
        heroTag: 'AppIconHeroTag',
        imagePath: AppImage.icIconHome,
        fit: BoxFit.contain,
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:omkar_sale/core/routes/app_routes.dart';
// import 'package:omkar_sale/utils/extensions/theme_extensions.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();

//   static Route route(RouteSettings routeSettings) {
//     return MaterialPageRoute(settings: routeSettings, builder: (_) => const SplashScreen());
//   }
// }

// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Offset> _floatingAnimation;

//   @override
//   void initState() {
//     super.initState();
//     navigatNextPage();
//     // Controller for the ambient floating movement of background circles
//     _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);

//     // Creates a slow drifting motion for the background blurs
//     _floatingAnimation = Tween<Offset>(begin: const Offset(-0.05, -0.05), end: const Offset(0.05, 0.05)).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
//   }

//   void navigatNextPage() {
//     Future.delayed(Duration(seconds: 2), () {
//       Navigator.pushReplacementNamed(context, Routes.home);
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isDark = Theme.of(context).brightness == Brightness.dark;
//     final Size size = MediaQuery.of(context).size;

//     return Scaffold(
//       body: Stack(
//         children: [
//           // Animated Background Blurs (Moving anywhere on screen)
//           AnimatedBuilder(
//             animation: _floatingAnimation,
//             builder: (context, child) {
//               return Stack(
//                 children: [
//                   Positioned(
//                     top: -size.height * 0.1 + (size.height * _floatingAnimation.value.dy),
//                     right: -size.width * 0.1 + (size.width * _floatingAnimation.value.dx),
//                     child: _buildBlurCircle(size.width * 0.8, context.primaryColor.withValues(alpha: .12)),
//                   ),
//                   Positioned(
//                     bottom: -size.height * 0.05 - (size.height * _floatingAnimation.value.dy),
//                     left: -size.width * 0.1 - (size.width * _floatingAnimation.value.dx),
//                     child: _buildBlurCircle(size.width * 0.9, context.primaryColor.withValues(alpha: .08)),
//                   ),
//                 ],
//               );
//             },
//           ),

//           // Main Content
//           SafeArea(
//             child: Column(
//               children: [
//                 const Spacer(),

//                 // Logo Section with Entrance Animation
//                 // Logo Section with Entrance Animation
//                 TweenAnimationBuilder<double>(
//                   tween: Tween(begin: 0.0, end: 1.0),
//                   duration: const Duration(milliseconds: 1200),
//                   curve: Curves.easeOutBack, // This curve overshoots 1.0, causing the crash
//                   builder: (context, value, child) {
//                     return Transform.scale(
//                       scale: value, // Scale can be > 1.0 (it looks like a bounce)
//                       child: Opacity(
//                         // FIX: Clamp the value so it never goes above 1.0 or below 0.0
//                         opacity: value.clamp(0.0, 1.0),
//                         child: child,
//                       ),
//                     );
//                   },
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         _buildLogoIcon(isDark),
//                         const SizedBox(height: 40),
//                         Text("Mercantile Pro", style: GoogleFonts.manrope(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: -1)),
//                         const SizedBox(height: 12),
//                         Text("Manage sales. Simplify orders.", style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w500)),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const Spacer(),

//                 // Footer with Slide-up Animation
//                 TweenAnimationBuilder<Offset>(
//                   tween: Tween(begin: const Offset(0, 20), end: Offset.zero),
//                   duration: const Duration(milliseconds: 1000),
//                   builder: (context, offset, child) {
//                     return Transform.translate(offset: offset, child: child);
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.only(bottom: 40),
//                     child: Text(
//                       "v1.0.2 • Build 8920",
//                       style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.white24 : Colors.black26),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBlurCircle(double size, Color color) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: color,
//         // Added shadow to make the "blur" feel softer
//         boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
//       ),
//     );
//   }

//   Widget _buildLogoIcon(bool isDark) {
//     return Container(
//       width: 128,
//       height: 128,
//       decoration: BoxDecoration(
//         color: context.scaffoldBackgroundColor,
//         borderRadius: BorderRadius.circular(32),
//         boxShadow: [BoxShadow(color: context.primaryColor.withValues(alpha: .3), blurRadius: 40, offset: const Offset(0, 10))],
//       ),
//       padding: const EdgeInsets.all(24),
//       child: Image.network(
//         "https://lh3.googleusercontent.com/aida-public/AB6AXuDqBejO66znRQeMjxQ_bndN84q1xg3GqjCBwIziDey9xoUqLVYVr6zdpGKGgI7hQ65tOWL6iW7Gyi2pL_qHdKkI4YaT7yxP_ssBIECyn5f20VvTmmXjGkRU3zukpLif8obIw1_FVHKkoNJg8di13N1-rdO364zgOWpnoOnVR2qT3MaMsZkY0Op7bEoU2yWBDK8e8ILAE6WkYBWT8uYEWaf6pJF8AU9eoXO6k6iTllKCHoU2nen_liTPGZ8wDrejp4sCS6EB4UKvNv8",
//         fit: BoxFit.contain,
//       ),
//     );
//   }
// }
