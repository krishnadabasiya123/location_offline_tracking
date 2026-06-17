import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omkar_sale/commons/widgets/show_user_session_expired_dialog.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/location/service/location_permission_guard.dart';
import 'package:omkar_sale/features/location/service/location_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();

  static Route<MainScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute<MainScreen>(
      settings: routeSettings,
      builder: (_) => const MainScreen(),
    );
  }
}

class _MainScreenState extends State<MainScreen> {
  ValueNotifier<int> currentTab = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    Future.microtask(fetchUserDetails);
  }

  void fetchUserDetails() {
    // if (context.read<UserDetailsCubit>().state is UserDetailsInitial || context.read<UserDetailsCubit>().state is UserDetailsFetchFailure) {
    context.read<UserDetailsCubit>().fetchUserDetails();
    //  }
  }

  void _showRestoreTrackingDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Force user interaction to ensure tracking starts
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  'Tracking Paused',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              'Your shift is currently active, but closing the app stopped background location tracking. Please resume tracking to continue your task and keep your shift active.',
              style: GoogleFonts.manrope(fontSize: 14),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  // 1. Re-check permissions FIRST (does not close the dialog yet)
                  final permissionsGranted = await LocationOnboarding.ensure(
                    context,
                  );

                  if (permissionsGranted) {
                    // 2. Only close (pop) the dialog if they successfully granted all permissions!
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    // 3. Restart the tracking service
                    await LocationTracker.instance.start();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Location tracking resumed successfully!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    // ⚠️ If permissions were denied/cancelled, the dialog stays open!
                    // This forces the user to grant them to continue using the app during their shift.
                  }
                },

                child: Text(
                  'Resume Tracking',
                  style: GoogleFonts.manrope(
                    color: context.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentTab,
      builder: (context, value, child) {
        return PopScope(
          canPop: currentTab.value == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return; // App is closing, no further action needed
            if (currentTab.value != 0) {
              currentTab.value = 0;
            }
          },
          child: Scaffold(
            // appBar: QAppBar(title: "My Profile", roundedAppBar: true, automaticallyImplyLeading: false),
            bottomNavigationBar: MediaQuery.removePadding(
              context: context,
              //removeBottom: Platform.isIOS,
              child: BottomNavContainer(
                selectedIndex: currentTab.value,
                onItemSelected: (index) {
                  if (context.read<UserDetailsCubit>().state
                      is! UserDetailsFetchSuccess) {
                    return;
                  }

                  currentTab.value = index;
                },
              ),
            ),

            body: BlocConsumer<UserDetailsCubit, UserDetailsState>(
              listener: (context, state) async {
                if (state is UserDetailsFetchFailure) {
                  if (state.exception.errorCode == 401) {
                    context.showSnackBar(
                      message:
                          '${state.exception.errorCode} ${state.exception.errorMessageKey}',
                      backgroundColor: AppThemeColors.amberColor,
                    );
                    await context.showSessionExpired();
                  }
                }

                if (state is UserDetailsFetchSuccess) {
                  final apiClockedIn = state.userDetail.hasClockedIn;
                  final localClockedIn = AuthLocalRepository.instance
                      .getClockedInStatus();
                  if (apiClockedIn) {
                    // ➡️ Query the active tracker domain singleton
                    final needsRestore = LocationTracker.instance
                        .shouldPromptRestore();
                    if (needsRestore) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _showRestoreTrackingDialog();
                      });
                    }
                  }

                  if (apiClockedIn && !localClockedIn) {
                    // Cross-device resume: this device has no local trace of
                    // an active shift, but the server still has one. Start
                    // the tracker so the shift continues on the new device.
                    if (!LocationTracker.instance.isRunning) {
                      print(
                        '🚀 MAIN SCREEN: Cross-device resume — starting location tracker',
                      );
                      await LocationTracker.instance.start();
                    }
                  } else if (!apiClockedIn && localClockedIn) {
                    // Server says the shift ended elsewhere — stop tracking
                    // and clear local state so we stay in sync.
                    await LocationTracker.instance.stop();
                  }

                  await AuthLocalRepository.instance.setClockedInStatus(
                    apiClockedIn,
                  );
                }
              },
              builder: (context, state) {
                state.log('UserDetailsCubit');
                if (state is UserDetailsFetchFailure) {
                  print('DEBUG: Entered UserDetailsFetchFailure block');
                  print('DEBUG: Exception: ${state.exception.errorMessageKey}');

                  return Center(
                    child: CustomErrorWidget(
                      errorType: state.exception.type,
                      onRetry: fetchUserDetails,
                    ),
                  );
                }
                if (state is UserDetailsFetchSuccess) {
                  // 1. Define the main content (The screens)
                  final Widget content = IndexedStack(
                    index: currentTab.value,
                    children: const [
                      HomeScreen(),
                      CustomerListScreen(),
                      SettingScreen(),
                    ],
                  );
                  // Always wrap with LocationPermissionGuard so location
                  // permissions + OEM battery / Auto-launch onboarding fire
                  // BEFORE the user can reach the Clock In button.
                  return LocationPermissionGuard(child: content);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        );
      },
    );
  }
}

class BottomNavContainer extends StatelessWidget {
  const BottomNavContainer({
    required this.selectedIndex,
    required this.onItemSelected,
    super.key,
  });
  final int selectedIndex;
  final void Function(int) onItemSelected;

  @override
  Widget build(BuildContext context) {
    const itemsCount = 3;
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / itemsCount;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      // Total height of the bar
      height: 65.sp(context) + bottomPadding,
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      // STACK is required for AnimatedPositioned to work
      child: Stack(
        children: [
          // 1. NAV ITEMS (Placed first so indicator stays on top)
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Row(
                children: [
                  _buildItem(
                    context,
                    index: 0,
                    label: 'homeLbl'.tr(context),
                    inactiveIcon: AppImage.homeInactive,
                    activeIcon: AppImage.homeActive,
                  ),
                  _buildItem(
                    context,
                    index: 1,
                    label: 'storeLbl'.tr(context),
                    inactiveIcon: AppImage.storeInactive,
                    activeIcon: AppImage.storeActive,
                  ),
                  // _buildItem(context, index: 2, label: 'productLbl'.tr(context), inactiveIcon: AppImage.productInactive, activeIcon: AppImage.productActive),
                  _buildItem(
                    context,
                    index: 2,
                    label: 'settingLbl'.tr(context),
                    inactiveIcon: AppImage.settingsInactive,
                    activeIcon: AppImage.settingsActive,
                  ),
                ],
              ),
            ),
          ),

          // 2. THE TRAVELING INDICATOR BAR
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            left: selectedIndex * tabWidth,
            top: 0,
            child: Container(
              width: tabWidth,
              alignment: Alignment.center,
              child: Container(
                width: tabWidth * 0.5,
                height: 4.sp(context),
                decoration: BoxDecoration(
                  color: context.colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required int index,
    required String label,
    required String inactiveIcon,
    required String activeIcon,
  }) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onItemSelected(index);
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- ICON ANIMATION ---
            AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(bottom: isSelected ? 18.sp(context) : 0),
              child: AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: CustomImageWidget(
                  imagePath: isSelected ? activeIcon : inactiveIcon,
                  fit: BoxFit.contain,
                  height: 24.sp(context),
                  color: isSelected
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),

            // --- TITLE ANIMATION ---
            // Removed the Container and used Stack properly
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              bottom: isSelected ? -2.sp(context) : -20.sp(context),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp(context),
                    fontWeight: FontWeight.w500,
                    color: context.colorScheme.onSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
