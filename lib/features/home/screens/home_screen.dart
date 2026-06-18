import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/commons/cubits/agenda_cubit.dart';
import 'package:omkar_sale/commons/cubits/set_agenda_cubit.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/home/widget/agenda_Item_container.dart';
import 'package:omkar_sale/features/home/widget/local_db_viewer_sheet.dart';
import 'package:omkar_sale/features/location/screen/location_disclosure_dialog.dart';
import 'package:omkar_sale/features/location/service/database_inspector.dart';
import 'package:omkar_sale/features/location/service/manual_sync_service.dart';
import 'package:permission_handler/permission_handler.dart';

// Dummy Data Section:
// This section provides placeholder content for UI components such as:
// - Home page summary cards
// - Store summary details
// - Location button actions
// These can be used for testing UI layout and interactions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Route<HomeScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute<HomeScreen>(
      settings: routeSettings,
      builder: (_) => const HomeScreen(),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<GetAgendaCubit>().fetchGetAgenda());
    _scrollController.addListener(scrollListenerM);
  }

  void scrollListenerM() {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.offset) {
      if (context.read<GetAgendaCubit>().hasMoreAgendas()) {
        context.read<GetAgendaCubit>().fetchMoreAgendas();
      }
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(scrollListenerM)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions once
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<UserDetailsCubit>().fetchUserDetails();
        },
        child: BlocBuilder<UserDetailsCubit, UserDetailsState>(
          builder: (context, state) {
            if (state is UserDetailsFetchSuccess) {
              final currentUser = state.userDetail;

              return Column(
                children: [
                  _buildHeader(userDetails: currentUser),

                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: CustomPaddingWidget.symmetric(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.sp(context)),

                            // 1. Clock Card (Using 35% of screen height)
                            _buildClockCard(
                              height: screenHeight * 0.3,
                              userDetails: currentUser,
                            ),

                            SizedBox(height: 20.sp(context)),

                            // Local DB Viewer Button
                            SizedBox(
                              width: double.infinity,
                              height: 48.sp(context),
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: context.primaryColor.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      16.sp(context),
                                    ),
                                  ),
                                  foregroundColor: context.primaryColor,
                                  backgroundColor:
                                      context.colorScheme.secondary,
                                ),
                                onPressed: () {
                                  DatabaseInspector.show(context);
                                },
                                icon: Icon(
                                  Icons.storage_rounded,
                                  size: 20.sp(context),
                                ),
                                label: Text(
                                  'Local Database Viewer',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp(context),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 20.sp(context)),

                            SizedBox(
                              width: double.infinity,
                              height: 48.sp(context),
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: context.primaryColor.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      16.sp(context),
                                    ),
                                  ),
                                  foregroundColor: context.primaryColor,
                                  backgroundColor:
                                      context.colorScheme.secondary,
                                ),
                                onPressed: () {
                                  _seedDummyData();
                                },
                                icon: Icon(
                                  Icons.storage_rounded,
                                  size: 20.sp(context),
                                ),
                                label: Text(
                                  'Add dummy data',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp(context),
                                  ),
                                ),
                              ),
                            ),

                            // 2. Quick Actions
                            Text(
                              'quickActionsLbl'.tr(context),
                              style: GoogleFonts.manrope(
                                fontSize: 18.sp(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12.sp(context)),

                            QuickActionWidget(
                              title: 'submitDailyReportLbl'.tr(context),
                              subtitle: 'shopWiseSummaryLbl'.tr(context),
                              icon: Icon(
                                Icons.assignment_outlined,
                                color: context.colorScheme.onPrimary,
                                size: 24.sp(context),
                              ),
                              color: context.primaryColor,
                              onTap: () => Navigator.of(
                                context,
                              ).pushNamed(Routes.dailyReportListScreen),
                            ),

                            if (context
                                .read<UserDetailsCubit>()
                                .isUserSalesman()) ...[
                              SizedBox(height: 12.sp(context)),
                              // Clear Dummy Locations: removes all test coordinates from Hive, resetting dummy data state.
                              // Clear Dummy Locations: removes all test coordinates from Hive, resetting dummy data state.
                              QuickActionWidget(
                                title: 'addShopLbl'.tr(context),
                                subtitle: 'registerShopLbl'.tr(context),
                                icon: Icon(
                                  Icons.person_add_alt_1,
                                  color: context.colorScheme.onPrimary,
                                  size: 24.sp(context),
                                ),
                                color: Colors.purple,
                                onTap: () => Navigator.of(
                                  context,
                                ).pushNamed(Routes.createShopScreen),
                              ),
                            ],

                            // --- DEBUG/DUMMY DATA SECTION ---
                            // if (kDebugMode) ...[
                            //   SizedBox(height: 12.sp(context)),
                            //   QuickActionWidget(
                            //     title: 'Store Dummy Locations',
                            //     subtitle: 'Injects test coordinates into Hive',
                            //     icon: Icon(Icons.bug_report, color: context.colorScheme.onPrimary, size: 24.sp(context)),
                            //     color: Colors.orange,
                            //     onTap: () {
                            //       context.read<ClockInOutCubit>().injectDummyLocations();
                            //       context.showSnackBar(
                            //         message: 'Dummy locations stored in Hive!',
                            //         backgroundColor: Colors.green,
                            //       );
                            //     },
                            //   ),

                            //   SizedBox(height: 12.sp(context)),
                            //   QuickActionWidget(
                            //     title: 'Clear Dummy Locations',
                            //     subtitle: 'Clears all test coordinates from Hive',
                            //     icon: Icon(Icons.delete_forever, color: context.colorScheme.onPrimary, size: 24.sp(context)),
                            //     color: Colors.redAccent,
                            //     onTap: () {
                            //       context.read<ClockInOutCubit>().clearDummyLocations();
                            //       context.showSnackBar(
                            //         message: 'All location points cleared!',
                            //         backgroundColor: Colors.red,
                            //       );
                            //     },
                            //   ),
                            // ],r
                            // --- END DEBUG SECTION ---
                            // --- END DEBUG SECTION ---
                            SizedBox(height: 30.sp(context)),

                            // 3. Agenda Header
                            BlocBuilder<GetAgendaCubit, GetAgendaState>(
                              builder: (context, state) {
                                if (state is GetAgendaFetchSuccess) {
                                  if (state.agendas.isEmpty) {
                                    return const SizedBox();
                                  }
                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'agendaLbl'.tr(context),
                                            style: GoogleFonts.manrope(
                                              fontSize: 18.sp(context),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12.sp(context)),

                                      PaginatedBlocListView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        items: state.agendas,
                                        //  scrollController: _scrollController,
                                        hasMore: context
                                            .read<GetAgendaCubit>()
                                            .hasMoreAgendas(),
                                        isLoading: state.isLoading,
                                        isInitialLoad: false,
                                        onLoadMore: () => context
                                            .read<GetAgendaCubit>()
                                            .fetchMoreAgendas(),
                                        itemBuilder: (context, item) =>
                                            BlocProvider<SetAgendaNotesCubit>(
                                              create: (context) =>
                                                  SetAgendaNotesCubit(),
                                              child: AgendaItemWidget(
                                                agendaDetails: item,
                                              ),
                                            ),
                                      ),
                                    ],
                                  );
                                }
                                return Container();
                              },
                            ),

                            // Bottom spacing for Safe Area
                            SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom +
                                  20.sp(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Center(child: CustomCircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Future<void> _seedDummyData() async {
    try {
      final boxName = ManualSyncService.instance.clockInOutDataBox;
      final locBoxName = ManualSyncService.instance.locationDataBox;

      final box = Hive.isBoxOpen(boxName)
          ? Hive.box<dynamic>(boxName)
          : await Hive.openBox<dynamic>(boxName);

      final locBox = Hive.isBoxOpen(locBoxName)
          ? Hive.box<dynamic>(locBoxName)
          : await Hive.openBox<dynamic>(locBoxName);

      await box.clear();
      await locBox.clear();

      final now = DateTime.now();
      final dateStr = DateFormat("dd-MM-yyyy").format(now);
      final year = now.year;
      final month = now.month;
      final day = now.day;

      final List<Map<String, dynamic>> sessions = [];
      final List<Map<String, dynamic>> locations = [];

      // CONFIGURATION: 8:00 to 13:00 (1 PM) and 14:00 (2 PM) to 17:00 (5 PM)
      final List<Map<String, dynamic>> shiftConfigs = [
        {
          "startHour": 8,
          "startMinute": 0,
          "endHour": 8, // Changed 1 to 13 (1 PM)
          "endMinute": 30,
          "inSync": false,
          "outSync": false,
        },
        {
          "startHour": 8,
          "startMinute": 45,
          "endHour": 9, // 5 PM
          "endMinute": 0,
          "inSync": false,
          "outSync": false,
        },
      ];

      for (int i = 0; i < shiftConfigs.length; i++) {
        final config = shiftConfigs[i];

        final int inTime = DateTime(
          year,
          month,
          day,
          config["startHour"] as int,
          config["startMinute"] as int,
        ).millisecondsSinceEpoch;
        final int outTime = DateTime(
          year,
          month,
          day,
          config["endHour"] as int,
          config["endMinute"] as int,
        ).millisecondsSinceEpoch;

        final double baseLat = 23.23825 + (i * 0.010);
        final double baseLong = 69.68097 + (i * 0.010);

        // 1. Add Clock-In for this shift
        sessions.add({
          "type": "in",
          "time": inTime,
          "lat": baseLat.toString(),
          "long": baseLong.toString(),
          "isSync": config["inSync"],
        });

        // 2. Add Clock-Out for this shift
        sessions.add({
          "type": "out",
          "time": outTime,
          "lat": (baseLat + 0.002).toString(),
          "long": (baseLong + 0.002).toString(),
          "isSync": config["outSync"],
        });

        // 3. Generate location points ONLY between this shift's start and end time
        int pointsPerShift = 500; // Total 1000 across both shifts
        final step = (outTime - inTime) ~/ pointsPerShift;

        for (int j = 0; j < pointsPerShift; j++) {
          locations.add({
            "date": dateStr,
            "time": inTime + (j * step),
            "lat": baseLat + (j * 0.00001),
            "long": baseLong + (j * 0.00001),
          });
        }
      }

      // Save to Hive
      await box.put(dateStr, sessions);
      await locBox.put(dateStr, {"location": locations});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Dummy data seeded for two shifts (8-1 and 2-5)"),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error seeding Hive data: $e");
    }
  }

  Widget _buildHeader({required UserDetails userDetails}) {
    return CustomAppBar(
      backgroundColor: context.colorScheme.secondary,
      elevation: 0,
      appBarHeight: (kToolbarHeight + 20).sp(context),
      title: Row(
        children: [
          Container(
            height: 48.sp(context),
            width: 48.sp(context),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: userDetails.imageUrl.isNotEmpty
                ? CustomImageWidget.circular(
                    imagePath: userDetails.imageUrl,
                    size: 48.sp(context),
                  )
                : Text(
                    UiUtils.twoCharacterString(userDetails.name),
                    style: TextStyle(
                      color: context.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp(context),
                    ),
                  ),
          ),

          // CircleAvatar(
          //   radius: 22.sp(context),
          //   child: CustomImageWidget.circular(imagePath: userDetails.u, size: 22.sp(context)),
          // ),
          SizedBox(width: 12.sp(context)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                userDetails.name,
                style: GoogleFonts.manrope(
                  fontSize: 16.sp(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                (userDetails.role == UserRole.salesman)
                    ? 'salesmanLbl'.tr(context)
                    : 'merchandiserLbl'.tr(context),
                style: GoogleFonts.manrope(
                  fontSize: 12.sp(context),
                  color: Colors.teal.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: false,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.notificationScreen);
          },
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildClockCard({
    required double height,
    required UserDetails userDetails,
  }) {
    final isClockedIn = userDetails.hasClockedIn;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30.sp(context)),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(32.sp(context)),
        border: Border.all(color: context.primaryColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onTertiary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'currentStatusLbl'.tr(context),
            style: TextStyle(
              fontSize: 14.sp(context),
              fontWeight: FontWeight.w500,
              color: context.colorScheme.onSecondary,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 8.sp(context)),

          // Status Chip
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.sp(context),
              vertical: 4.sp(context),
            ),
            decoration: BoxDecoration(
              color: isClockedIn
                  ? AppThemeColors.greenColor.withValues(alpha: 0.15)
                  : context.colorScheme.onSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isClockedIn
                    ? AppThemeColors.greenColor.withValues(alpha: 0.2)
                    : context.colorScheme.onSecondary.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  color: isClockedIn
                      ? AppThemeColors.greenColor
                      : context.colorScheme.surfaceDim,
                  size: 8.sp(context),
                ),
                SizedBox(width: 8.sp(context)),
                Text(
                  (isClockedIn ? 'shiftActiveLbl' : 'shiftInactiveLbl').tr(
                    context,
                  ),
                  style: TextStyle(
                    fontSize: 11.sp(context),
                    fontWeight: FontWeight.w500,
                    color: isClockedIn
                        ? AppThemeColors.greenColor
                        : context.colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.sp(context)),
          // Clock Button
          BlocConsumer<ClockInOutCubit, ClockInOutState>(
            listener: (context, state) {
              if (state is ClockInOuSuccess) {
                state.isClockIn.log('ClockInOutCubit');
                context.read<UserDetailsCubit>().updateUserShiftStatus(
                  newStatus: !state.isClockIn,
                );
                context.showSnackBar(
                  message: 'clockInOutSuccessLbl'.tr(
                    context,
                    namedArgs: {'isClockIn': state.isClockIn ? 'out' : 'in'},
                  ),
                  backgroundColor: context.colorScheme.primary,
                );
              }
              if (state is ClockInOutFetchFailure) {
                context.showSnackBar(
                  message: state.exception.errorMessageKey.tr(context),
                  backgroundColor: context.colorScheme.error,
                );
              }
            },
            builder: (context, state) {
              // state.log('ClockInOutCubit');
              if (state is ClockInOutInProgress) {
                return const Center(child: CustomCircularProgressIndicator());
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: context.screenWidth * 0.65,
                    height: 1.sp(context),
                    color: context.colorScheme.surfaceDim.withValues(
                      alpha: 0.15,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // --- PRODUCTION NOTE: Play Store Background Location Compliance ---
                      // When uploading to the Play Store, ensure that:
                      // 1. The background location usage is clearly disclosed to the user (implemented via showLocationDisclosure).
                      // 2. The app's functionality (tracking visits/attendance) justifies the "Always" permission.
                      // 3. You have updated the "Data Safety" section in the Play Console to reflect location data collection.

                      // Step 0: Ensure Notification Permission (Android 13+)
                      final notificationStatus =
                          await Permission.notification.status;
                      if (!notificationStatus.isGranted) {
                        await Permission.notification.request();
                      }

                      // Step 1: Check/Request "When In Use" First (System Dialog)
                      var whenInUse = await Permission.location.status;

                      if (!whenInUse.isGranted) {
                        // If permanently denied, show disclosure (as explanation) then settings
                        if (whenInUse.isPermanentlyDenied) {
                          final accepted = await showLocationDisclosure(
                            context,
                            force: true,
                          );
                          if (accepted && context.mounted)
                            await openAppSettings();
                          return;
                        }

                        // Request "When In Use" directly (System Dialog)
                        whenInUse = await Permission.location.request();
                        if (!whenInUse.isGranted) return; // User denied, stop
                      }

                      // Step 2: Check "Always" (Background) - Requires Disclosure
                      var alwaysStatus = await Permission.locationAlways.status;

                      if (!alwaysStatus.isGranted) {
                        // Show Prominent Disclosure (Mandatory before requesting background)
                        final accepted = await showLocationDisclosure(
                          context,
                          force: true,
                        );
                        if (!accepted || !context.mounted) return;

                        if (alwaysStatus.isPermanentlyDenied) {
                          await openAppSettings();
                          return;
                        }

                        // Request "Always"
                        alwaysStatus = await Permission.locationAlways
                            .request();

                        // If still not granted/permanently denied, open settings
                        if (!alwaysStatus.isGranted) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select "Allow all the time" in Settings to clock in.',
                                ),
                              ),
                            );
                            await openAppSettings();
                          }
                          return;
                        }
                      }

                      // Step 2.5: Check master GPS switch (separate from permission)
                      var gpsOn = await Geolocator.isLocationServiceEnabled();
                      if (!gpsOn) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please turn on GPS to clock in.'),
                            ),
                          );
                        }
                        await Geolocator.openLocationSettings();
                        // Poll up to 60s for user to enable GPS
                        const maxWait = Duration(seconds: 60);
                        final deadline = DateTime.now().add(maxWait);
                        while (!gpsOn && DateTime.now().isBefore(deadline)) {
                          await Future<void>.delayed(
                            const Duration(seconds: 1),
                          );
                          gpsOn = await Geolocator.isLocationServiceEnabled();
                        }
                        if (!gpsOn) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'GPS still off. Please enable and try again.',
                                ),
                              ),
                            );
                          }
                          return;
                        }
                      }

                      // Step 2.7: Physical Activity Recognition permission.
                      // Required by tracelet for motion-based wake-ups on Android 10+.
                      // Must be granted BEFORE the clock-in/out API call so we don't
                      // start a shift that the tracker can't reliably maintain.
                      if (Platform.isAndroid) {
                        var activityStatus =
                            await Permission.activityRecognition.status;
                        if (!activityStatus.isGranted) {
                          if (activityStatus.isPermanentlyDenied) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enable Physical Activity permission in Settings to clock in.',
                                  ),
                                ),
                              );
                              await Future.delayed(const Duration(seconds: 3));
                              await openAppSettings();
                            }
                            return;
                          }
                          activityStatus = await Permission.activityRecognition
                              .request();
                          if (!activityStatus.isGranted) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enable Physical Activity permission in Settings to clock in.',
                                  ),
                                ),
                              );
                              await openAppSettings();
                            }
                            return;
                          }
                        }
                      }

                      // Step 3: All Permissions Granted — Proceed
                      if (context.mounted) {
                        context.read<ClockInOutCubit>().setClockInOut(
                          isClockIn: isClockedIn,
                        );
                      }
                    },
                    child: Container(
                      height: height * 0.45,
                      width: height * 0.45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isClockedIn
                              ? [
                                  const Color(0xFFF43F5E),
                                  const Color(0xFFE11D48),
                                ]
                              : [
                                  const Color(0xFF137FEC),
                                  const Color(0xFF0B63BE),
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isClockedIn ? Colors.red : Colors.blue)
                                .withValues(alpha: 0.5),
                            blurRadius: 35,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: context.colorScheme.surface.withValues(
                            alpha: 0.5,
                          ),
                          width: 4,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isClockedIn ? Icons.logout : Icons.login,
                            color: context.colorScheme.onPrimary,
                            size: height * 0.12,
                          ),
                          Text(
                            (isClockedIn ? 'clockOutLbl' : 'clockInLbl').tr(
                              context,
                            ),
                            style: TextStyle(
                              color: context.colorScheme.onPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 11.sp(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget _buildQuickActions(BuildContext context) {
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       final avilabileWidth = constraints.maxWidth - (16.sp(context));
  //       final singleContainerWidth = avilabileWidth / 2;
  //       return Row(
  //         children: [
  //           _expandedActionCard(title: 'newOrderLbl'.tr(context), subtitle: 'startASale'.tr(context), icon: Icons.add_shopping_cart, color: const Color(0xFF137FEC), width: singleContainerWidth),
  //           SizedBox(width: 16.sp(context)),
  //           _expandedActionCard(title: 'addShopLbl'.tr(context), subtitle: 'registerShopLbl'.tr(context), icon: Icons.person_add_alt_1, color: Colors.purple, width: singleContainerWidth),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Widget _expandedActionCard({required String title, required String subtitle, required IconData icon, required Color color, required double width}) {
  //   return Expanded(
  //     child: Container(
  //       width: width,
  //       height: width,
  //       decoration: BoxDecoration(
  //         color: context.colorScheme.secondary,
  //         borderRadius: BorderRadius.circular(28.sp(context)),
  //         border: Border.all(color: context.primaryColor.withValues(alpha: 0.1)),
  //         boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 15)],
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Container(
  //             padding: EdgeInsets.all(14.sp(context)),
  //             decoration: BoxDecoration(color: color.withValues(alpha:0.2), borderRadius: BorderRadius.circular(10.sp(context))),
  //             child: Icon(icon, color: color, size: 25.sp(context)),
  //           ),
  //           SizedBox(height: 12.sp(context)),
  //           Text(
  //             title,
  //             style: TextStyle(color: context.colorScheme.onTertiary.withValues(alpha: 0.8), fontWeight: FontWeight.bold, fontSize: 16.sp(context)),
  //           ),
  //           Text(
  //             subtitle,
  //             style: TextStyle(color: context.colorScheme.onTertiary.withValues(alpha:0.6), fontSize: 13.sp(context)),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class QuickActionWidget extends StatefulWidget {
  const QuickActionWidget({
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    super.key,
  });

  final void Function() onTap;
  final String title;
  final String subtitle;
  final Widget icon;
  final Color color;

  @override
  State<QuickActionWidget> createState() => _QuickActionWidgetState();
}

class _QuickActionWidgetState extends State<QuickActionWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: Container(
        // margin: EdgeInsets.symmetric(horizontal: 16.sp(context)),
        padding: EdgeInsets.all(16.sp(context)),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12.sp(context)), // rounded-xl
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container (p-2 bg-white/20 rounded-lg)
            Container(
              padding: EdgeInsets.all(10.sp(context)),
              decoration: BoxDecoration(
                color: context.colorScheme.onPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.icon,
            ),
            SizedBox(width: 16.sp(context)),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: context.colorScheme.onPrimary,
                      fontSize: 16.sp(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      color: context.colorScheme.onPrimary.withValues(
                        alpha: 0.85,
                      ),
                      fontSize: 12.sp(context),
                    ),
                  ),
                ],
              ),
            ),
            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              color: context.colorScheme.onPrimary,
              size: 16.sp(context),
            ),
          ],
        ),
      ),
    );
  }
}
